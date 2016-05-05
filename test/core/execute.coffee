
{EventEmitter} = require 'events'
stream = require 'stream'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'execute', ->

  scratch = test.scratch @

  they 'in option cmd or as a string', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: 'text=yes; echo $text'
    , (err, status, stdout, stderr) ->
      status.should.be.true() unless err
      stdout.should.eql 'yes\n' unless err
    .execute 'text=yes; echo $text', (err, status, stdout, stderr) ->
      status.should.be.true() unless err
      stdout.should.eql 'yes\n' unless err
    .then next

  they 'cmd as a function', (ssh, next) ->
    mecano
      ssh: ssh
    .call (options) ->
      @test_context = 'test context'
      options.store.test_options = 'test options'
    .execute
      cmd: -> "text='#{@test_context}'; echo $text"
    , (err, status, stdout, stderr) ->
      stdout.should.eql 'test context\n' unless err
    .execute
      cmd: (options) -> "text='#{options.store.test_options}'; echo $text"
    , (err, status, stdout, stderr) ->
      stdout.should.eql 'test options\n' unless err
    .then next

  they 'stream stdout and unpipe', (ssh, next) -> #.skip 'remote',
    @timeout 10000000
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
    mecano
      ssh: ssh
    .execute
      cmd: "cat #{__filename} | grep #{search1}"
      stdout: out
    .execute
      cmd: "cat #{__filename} | grep #{search2}"
      stdout: out
    , (err, executed, stdout, stderr) ->
      unpiped.should.eql 2
      data.should.containEql search1
      data.should.containEql search2
      next()

  they 'stdout and stderr return empty', (ssh, next) -> #.skip 'remote',
    mecano.execute
      ssh: ssh
      cmd: "echo 'some text' | grep nothing"
    , (err, executed, stdout, stderr) ->
      stdout.should.eql ''
      stderr.should.eql ''
      next()

  they 'validate exit code', (ssh, next) ->
    # code undefined
    mecano
      ssh: ssh
    .execute
      cmd: "exit 42"
    .then (err, executed) ->
      err.message.should.eql 'Invalid Exit Code: 42'
    .execute
      cmd: "exit 42"
      code: [0, 42]
    .then (err, executed) ->
      next err

  they 'should honor code skipped', (ssh, next) ->
    # code undefined
    mecano
      ssh: ssh
    .execute
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.be.true()
    .execute
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.be.false()
      next()

  they 'should honor conditions', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: 'text=yes; echo $text'
      if_exists: __dirname
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
      stdout.should.eql 'yes\n'
    .execute
      cmd: 'text=yes; echo $text'
      if_exists: "__dirname/toto"
    , (err, executed, stdout, stderr) ->
      executed.should.be.false()
      should.not.exist stdout
      next()

  they 'honor unless_exists', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: "ls -l #{__dirname}"
      unless_exists: __dirname
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.be.false()
      next()

  describe 'log', ->

    they 'stdin, stdout, stderr', (ssh, next) ->
      stdin = stdout = stderr = undefined
      mecano
        ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stderr', (log) -> stderr = log
      .execute
        cmd: "echo 'to stderr' >&2; echo 'to stdout';"
      , (err, status) ->
        stdin.message.should.match /^echo.*;$/
        stdout.message.should.eql 'to stdout\n'
        stderr.message.should.eql 'to stderr\n'
      .then next

    they 'disable logging', (ssh, next) ->
      stdin = stdout = stderr = undefined
      stdout_stream = stderr_stream = []
      mecano
        ssh: ssh
      .on 'stdin', (log) -> stdin = log
      .on 'stdout', (log) -> stdout = log
      .on 'stdout_stream', (log) -> stdout_stream.push log
      .on 'stderr', (log) -> stderr = log
      .on 'stderr_stream', (log) -> stderr_stream.push log
      .execute
        cmd: "echo 'to stderr' >&2; echo 'to stdout';"
        stdout_log: undefined
        stderr_log: undefined
      , (err, status) ->
        stdin.message.should.match /^echo.*;$/
        (stdout is undefined).should.be.true()
        stdout_stream.length.should.eql 0
        (stderr is undefined).should.be.true()
        stderr_stream.length.should.eql 0
      .execute
        cmd: "echo 'to stderr' >&2; echo 'to stdout';"
        stdout_log: null
        stderr_log: null
      , (err, status) ->
        stdin.message.should.match /^echo.*;$/
        (stdout is undefined).should.be.true()
        stdout_stream.length.should.eql 0
        (stderr is undefined).should.be.true()
        stderr_stream.length.should.eql 0
      .execute
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
      mecano.execute
        ssh: ssh
        cmd: """
        sh -c '>&2 echo "Some Error"; exit 2'
        """
      , (err, _, stdout, stderr) ->
        err.message.should.eql 'Invalid Exit Code: 2'
        stdout.should.eql ''
        stderr.should.eql 'Some Error\n'
        next()

    they 'trap on error', (ssh, next) ->
      mecano
        ssh: ssh
      .execute
        cmd: """
        sh -c '>&2 echo "exit 2'
        echo 'ok'
        """
      , (err) ->
        return next err if err
      .execute
        cmd: """
        sh -c '>&2 echo "exit 2'
        echo 'ok'
        """
        trap: true
      , (err) ->
        err.should.be.an.Error
        next()
