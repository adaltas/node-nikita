
import stream from 'node:stream'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.execute', ->
  return unless test.tags.posix

  describe 'config `command`', ->

    they 'as a string', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: 'text=yes; echo $text'
        .should.be.finally.containEql
          $status: true
          stdout: 'yes\n'

    they 'as an argument', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @execute 'text=yes; echo $text'
        .should.be.finally.containEql
          $status: true
          stdout: 'yes\n'

    they 'as an action handler returning a string', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          a_key: 'test context'
          command: ({config}) ->
            "text='#{config.a_key}'; echo $text"
        .should.be.finally.containEql
          stdout: 'test context\n'

    they 'as an action handler returning a promise', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          a_key: 'test context'
          command: ({config}) ->
            new Promise (resolve, reject) ->
              resolve "text='#{config.a_key}'; echo $text"
        .should.be.finally.containEql
          stdout: 'test context\n'

  describe 'stream', ->

    they 'stdout and unpipe', ({ssh}) ->
      writer_done = callback_done = null
      data = ''
      out = new stream.Writable
      out._write = (chunk, encoding, callback) ->
        data += chunk.toString()
        callback()
      unpiped = 0
      out.on 'unpipe', ->
        unpiped++
      out.on 'finish', ->
        false.should.be.true()
      await nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          content: '''
          Test search_1.
          Test search_2.
          '''
          target: "#{tmpdir}/a_file"
        await @execute
          command: "cat #{tmpdir}/a_file | grep search_1"
          stdout: out
        await @execute
          command: "cat #{tmpdir}/a_file | grep search_2"
          stdout: out
      unpiped.should.eql 2
      data.should.containEql 'search_1'
      data.should.containEql 'search_2'

    they 'stdout and stderr return empty on command error', ({ssh}) ->
      nikita
        $ssh: ssh
      .execute
        command: "echo 'some text' | grep nothing"
        code: 1
      .should.be.finally.containEql
        stdout: ''
        stderr: ''

  describe 'trim', ->

    they 'both stdout and stderr', ({ssh}) ->
      nikita
        $ssh: ssh
      .execute
        command: """
        echo '  bonjour  '
        echo ' monde  ' >&2
        """
        trim: true
      .should.be.finally.containEql
        stdout: 'bonjour'
        stderr: 'monde'

    they 'with trim_stdout and trim_stderr', ({ssh}) ->
      nikita
        $ssh: ssh
      .execute
        command: """
        echo '  bonjour  '
        echo ' monde  ' >&2
        """
        stdout_trim: true
        stderr_trim: true
      .should.be.finally.containEql
        stdout: 'bonjour'
        stderr: 'monde'

  describe 'log', ->

    they.skip 'stdin, stdout, stderr', ({ssh}) ->
      stdin = stdout = stderr = undefined
      nikita
        $ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stderr', (log) -> stderr = log
      .execute
        command: "echo 'to stderr' >&2; echo 'to stdout';"
      , (err) ->
        stdin.message.should.match /^echo.*;$/
        stdout.message.should.eql 'to stdout\n'
        stderr.message.should.eql 'to stderr\n'

    they.skip 'disable logging', ({ssh}) ->
      stdin = stdout = stderr = undefined
      stdout_stream = stderr_stream = []
      nikita
        $ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stdout_stream', (log) -> stdout_stream.push log
      .on 'stderr', (log) -> stderr = log
      .on 'stderr_stream', (log) -> stderr_stream.push log
      .execute
        command: "echo 'to stderr' >&2; echo 'to stdout';"
        stdout_log: false
        stderr_log: false
      , (err) ->
        stdin.message.should.match /^echo.*;$/
        (stdout is undefined).should.be.true()
        stdout_stream.length.should.eql 0
        (stderr is undefined).should.be.true()
        stderr_stream.length.should.eql 0

  describe 'trap', ->

    they 'trap on error', ({ssh}) ->
      nikita $ssh: ssh, ->
        await @execute
          command: """
          sh -c '>&2 echo "exit 2'
          echo 'ok'
          """
        await @execute
          command: """
          sh -c '>&2 echo "exit 2'
          echo 'ok'
          """
          trap: true
        .should.be.rejected()

  describe 'error', ->

    they 'provide `stdout` and `stderr`', ({ssh}) ->
      nikita
        $ssh: ssh
      .execute
        command: """
        sh -c '>&2 echo "Some Error"; exit 2'
        """
      .should.be.rejectedWith
        code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID'
        message: [
          'NIKITA_EXECUTE_EXIT_CODE_INVALID: an unexpected exit code was encountered,'
          'command is "sh -c \'>&2 echo \\"Some Error\\"; exit 2\'",'
          'got 2 instead of {"true":[0],"false":[]}.'
        ].join ' '
        command: 'sh -c \'>&2 echo "Some Error"; exit 2\''
        exit_code: 2
        stdout: ''
        stderr: 'Some Error\n'
        $status: false

  describe 'dry', ->
    
    they 'dont execute the command', ({ssh}) ->
      (
        await nikita.execute
          command: "exit 1"
          dry: true
      ).should.match
        stdout: []
        stderr: []
        code: null
        $status: false
        $logs: (it) -> it.should.be.an.Array()
