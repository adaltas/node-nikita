
{EventEmitter} = require 'events'
should = require 'should'
stream = require 'stream'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
they = require 'ssh2-they'

describe 'execute', ->

  scratch = test.scratch @

  they 'run a command', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: 'text=yes; echo $text'
      toto: true
    , (err, executed, stdout, stderr) ->
      executed.should.equal 1
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
      false.should.be.ok
    mecano.execute
      ssh: ssh
      cmd: "cat #{__filename} | grep #{search1}"
      stdout: out
    , (err, executed, stdout, stderr) ->
      mecano.execute
        ssh: ssh
        cmd: "cat #{__filename} | grep #{search2}"
        stdout: out
      , (err, executed, stdout, stderr) ->
        unpiped.should.eql 2
        data.should.include search1
        data.should.include search2
        next()
  
  they 'validate exit code', (ssh, next) ->
    # code undefined
    mecano.execute
      ssh: ssh
      cmd: "chown"
    , (err, executed, stdout, stderr) ->
      err.message.should.eql 'Invalid Exit Code: 1'
      # code defined in array
      mecano.execute
        ssh: ssh
        cmd: "chown"
        code: [0, 1]
      , (err, executed, stdout, stderr) ->
        return next err if err
        next()
  
  they 'should honor code skipped', (ssh, next) ->
    # code undefined
    mecano.execute
      ssh: ssh
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.eql 1
      mecano.execute
        ssh: ssh
        cmd: "mkdir #{scratch}/my_dir"
        code: 0
        code_skipped: 1
      , (err, executed, stdout, stderr) ->
        return next err if err
        executed.should.eql 0
        next()
  
  they 'should honor conditions', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: 'text=yes; echo $text'
      if_exists: __dirname
    , (err, executed, stdout, stderr) ->
      executed.should.eql 1
      stdout.should.eql 'yes\n'
      mecano.execute
        ssh: ssh
        cmd: 'text=yes; echo $text'
        if_exists: "__dirname/toto"
      , (err, executed, stdout, stderr) ->
        executed.should.eql 0
        should.not.exist stdout
        next()

  they 'honor not_if_exists', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: "ls -l #{__dirname}"
      not_if_exists: __dirname
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.eql 0
      next()

  they 'trap on error', (ssh, next) ->
    mecano.execute
      ssh: ssh
      cmd: """
      ls -l /does/not/exist
      echo 'ok'
      """
    , (err) ->
      should.not.exists err
      mecano.execute
        ssh: ssh
        cmd: """
        ls -l /does/not/exist
        echo 'ok'
        """
        trap_on_error: true
      , (err) ->
        should.exists err
        err.code.should.eql 1
        next()


