
{EventEmitter} = require 'events'
stream = require 'stream'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'execute', ->

  scratch = test.scratch @

  they 'run a command', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: 'text=yes; echo $text'
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
      stdout.should.eql 'yes\n'
      next()
  
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
      cmd: "ls -l #{scratch}/doesnt_exist"
    .then (err, executed) ->
      err.message.should.eql 'Invalid Exit Code: 1'
    .execute
      cmd: "ls -l #{scratch}/doesnt_exist"
      code: [0, 1]
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

  they 'honor not_if_exists', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: "ls -l #{__dirname}"
      not_if_exists: __dirname
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.be.false()
      next()

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
        trap_on_error: true
      , (err) ->
        err.should.be.an.Error
        err.code.should.eql 2
        next()


