
stream = require 'stream'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'system.execute', ->

  they 'in option cmd or as a string', (ssh) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: 'text=yes; echo $text'
    , (err, {status, stdout}) ->
      status.should.be.true() unless err
      stdout.should.eql 'yes\n' unless err
    .system.execute 'text=yes; echo $text', (err, {status, stdout}) ->
      status.should.be.true() unless err
      stdout.should.eql 'yes\n' unless err
    .promise()

  they 'cmd as a function', (ssh) ->
    nikita
      ssh: ssh
    .call ->
      @store['test:a_key'] = 'test context'
    .system.execute
      cmd: -> "text='#{@store['test:a_key']}'; echo $text"
    , (err, {status, stdout}) ->
      stdout.should.eql 'test context\n' unless err
    .system.execute
      a_key: 'test options'
      cmd: ({options}) -> "text='#{options.a_key}'; echo $text"
    , (err, {status, stdout}) ->
      stdout.should.eql 'test options\n' unless err
    .promise()

  they 'stream stdout and unpipe', (ssh) ->
    writer_done = callback_done = null
    data = ''
    out = new stream.Writable
    out._write = (chunk, encoding, callback) ->
      data += chunk.toString()
      callback()
    search1 = 'search_toto'
    search2 = 'search_lulu'
    unpiped = 0
    out.on 'unpipe', ->
      unpiped++
    out.on 'finish', ->
      false.should.be.true()
    nikita
      ssh: ssh
    .system.execute
      cmd: "cat #{__filename} | grep #{search1}"
      stdout: out
    .system.execute
      cmd: "cat #{__filename} | grep #{search2}"
      stdout: out
    , (err) ->
      unpiped.should.eql 2
      data.should.containEql search1
      data.should.containEql search2
    .promise()

  they 'stdout and stderr return empty', (ssh) -> #.skip 'remote',
    nikita
      ssh: ssh
    .system.execute
      cmd: "echo 'some text' | grep nothing"
      relax: true
    , (err, {stdout, stderr}) ->
      stdout.should.eql '' unless err
      stderr.should.eql '' unless err
    .promise()

  they 'validate exit code', (ssh) ->
    # code undefined
    nikita
      ssh: ssh
    .system.execute
      cmd: "exit 42"
    .next (err) ->
      err.message.should.eql 'Invalid Exit Code: 42'
    .system.execute
      cmd: "exit 42"
      code: [0, 42]
    .promise()

  they 'should honor code skipped', (ssh) ->
    # code undefined
    nikita
      ssh: ssh
    .system.execute
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, {status}) ->
      status.should.be.true() unless err
    .system.execute
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should honor conditions', (ssh) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: 'text=yes; echo $text'
      if_exists: __dirname
    , (err, {status, stdout}) ->
      status.should.be.true()
      stdout.should.eql 'yes\n'
    .system.execute
      cmd: 'text=yes; echo $text'
      if_exists: "__dirname/toto"
    , (err, {status, stdout}) ->
      status.should.be.false()
      should.not.exist stdout
    .promise()

  they 'honor unless_exists', (ssh) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "ls -l #{__dirname}"
      unless_exists: __dirname
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  describe 'trim', ->

    they 'both stdout and stderr', (ssh) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        echo '  bonjour  '
        echo ' monde  ' >&2
        """
        trim: true
      , (err, {stdout, stderr}) ->
        stdout.should.eql 'bonjour' unless err
        stderr.should.eql 'monde' unless err
      .promise()

    they 'with trim_stdout and trim_stderr', (ssh) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        echo '  bonjour  '
        echo ' monde  ' >&2
        """
        stdout_trim: true
        stderr_trim: true
      , (err, {stdout, stderr}) ->
        stdout.should.eql 'bonjour' unless err
        stderr.should.eql 'monde' unless err
      .promise()

  describe 'log', ->

    they 'stdin, stdout, stderr', (ssh) ->
      stdin = stdout = stderr = undefined
      nikita
        ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stderr', (log) -> stderr = log
      .system.execute
        cmd: "echo 'to stderr' >&2; echo 'to stdout';"
      , (err) ->
        stdin.message.should.match /^echo.*;$/
        stdout.message.should.eql 'to stdout\n'
        stderr.message.should.eql 'to stderr\n'
      .promise()

    they 'disable logging', (ssh) ->
      stdin = stdout = stderr = undefined
      stdout_stream = stderr_stream = []
      nikita
        ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stdout_stream', (log) -> stdout_stream.push log
      .on 'stderr', (log) -> stderr = log
      .on 'stderr_stream', (log) -> stderr_stream.push log
      .system.execute
        cmd: "echo 'to stderr' >&2; echo 'to stdout';"
        stdout_log: false
        stderr_log: false
      , (err) ->
        stdin.message.should.match /^echo.*;$/
        (stdout is undefined).should.be.true()
        stdout_stream.length.should.eql 0
        (stderr is undefined).should.be.true()
        stderr_stream.length.should.eql 0
      .promise()

  describe 'error', ->

    they 'provide stdout and stderr', (ssh) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        sh -c '>&2 echo "Some Error"; exit 2'
        """
        relax: true
      , (err, {stdout, stderr}) ->
        err.message.should.eql 'Invalid Exit Code: 2'
        stdout.should.eql ''
        stderr.should.eql 'Some Error\n'
      .promise()

    they 'trap on error', (ssh) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        sh -c '>&2 echo "exit 2'
        echo 'ok'
        """
      .system.execute
        cmd: """
        sh -c '>&2 echo "exit 2'
        echo 'ok'
        """
        trap: true
        relax: true
      , (err) ->
        err.should.be.an.Error
      .promise()
