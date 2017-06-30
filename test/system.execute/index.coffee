
{EventEmitter} = require 'events'
stream = require 'stream'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.execute', ->

  scratch = test.scratch @

  they 'in option cmd or as a string', (ssh, next) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: 'text=yes; echo $text'
    , (err, status, stdout, stderr) ->
      status.should.be.true() unless err
      stdout.should.eql 'yes\n' unless err
    .system.execute 'text=yes; echo $text', (err, status, stdout, stderr) ->
      status.should.be.true() unless err
      stdout.should.eql 'yes\n' unless err
    .then next

  they 'cmd as a function', (ssh, next) ->
    nikita
      ssh: ssh
    .call (options) ->
      @test_context = 'test context'
      options.store.test_options = 'test options'
    .system.execute
      cmd: -> "text='#{@test_context}'; echo $text"
    , (err, status, stdout, stderr) ->
      stdout.should.eql 'test context\n' unless err
    .system.execute
      cmd: (options) -> "text='#{options.store.test_options}'; echo $text"
    , (err, status, stdout, stderr) ->
      stdout.should.eql 'test options\n' unless err
    .then next

  they 'stream stdout and unpipe', (ssh, next) ->
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
    , (err, status, stdout, stderr) ->
      unpiped.should.eql 2
      data.should.containEql search1
      data.should.containEql search2
    .then next

  they 'stdout and stderr return empty', (ssh, next) -> #.skip 'remote',
    nikita
      ssh: ssh
    .system.execute
      cmd: "echo 'some text' | grep nothing"
      relax: true
    , (err, status, stdout, stderr) ->
      stdout.should.eql '' unless err
      stderr.should.eql '' unless err
    .then next

  they 'validate exit code', (ssh, next) ->
    # code undefined
    nikita
      ssh: ssh
    .system.execute
      cmd: "exit 42"
    .then (err, status) ->
      err.message.should.eql 'Invalid Exit Code: 42'
    .system.execute
      cmd: "exit 42"
      code: [0, 42]
    .then next

  they 'should honor code skipped', (ssh, next) ->
    # code undefined
    nikita
      ssh: ssh
    .system.execute
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, status, stdout, stderr) ->
      status.should.be.true() unless err
    .system.execute
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, status, stdout, stderr) ->
      status.should.be.false() unless err
    .then next

  they 'should honor conditions', (ssh, next) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: 'text=yes; echo $text'
      if_exists: __dirname
    , (err, status, stdout, stderr) ->
      status.should.be.true()
      stdout.should.eql 'yes\n'
    .system.execute
      cmd: 'text=yes; echo $text'
      if_exists: "__dirname/toto"
    , (err, status, stdout, stderr) ->
      status.should.be.false()
      should.not.exist stdout
    .then next

  they 'honor unless_exists', (ssh, next) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "ls -l #{__dirname}"
      unless_exists: __dirname
    , (err, status, stdout, stderr) ->
      status.should.be.false() unless err
    .then next

  describe 'trim', ->
    
    they 'both stdout and stderr', (ssh, next) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        echo '  bonjour  '
        echo ' monde  ' >&2
        """
        trim: true
      , (err, status, stdout, stderr) ->
        stdout.should.eql 'bonjour' unless err
        stderr.should.eql 'monde' unless err
      .then next
        
    they 'with trim_stdout and trim_stderr', (ssh, next) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        echo '  bonjour  '
        echo ' monde  ' >&2
        """
        stdout_trim: true
        stderr_trim: true
      , (err, status, stdout, stderr) ->
        stdout.should.eql 'bonjour' unless err
        stderr.should.eql 'monde' unless err
      .then next

  describe 'log', ->

    they 'stdin, stdout, stderr', (ssh, next) ->
      stdin = stdout = stderr = undefined
      nikita
        ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stderr', (log) -> stderr = log
      .system.execute
        cmd: "echo 'to stderr' >&2; echo 'to stdout';"
      , (err, status) ->
        stdin.message.should.match /^echo.*;$/
        stdout.message.should.eql 'to stdout\n'
        stderr.message.should.eql 'to stderr\n'
      .then next

    they 'disable logging', (ssh, next) ->
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
      , (err, status) ->
        stdin.message.should.match /^echo.*;$/
        (stdout is undefined).should.be.true()
        stdout_stream.length.should.eql 0
        (stderr is undefined).should.be.true()
        stderr_stream.length.should.eql 0
      .then next

  describe 'error', ->

    they 'provide stdout and stderr', (ssh, next) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        sh -c '>&2 echo "Some Error"; exit 2'
        """
        relax: true
      , (err, _, stdout, stderr) ->
        err.message.should.eql 'Invalid Exit Code: 2'
        stdout.should.eql ''
        stderr.should.eql 'Some Error\n'
      .then next

    they 'trap on error', (ssh, next) ->
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
      .then next
