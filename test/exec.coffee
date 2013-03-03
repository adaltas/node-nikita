
{EventEmitter} = require 'events'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'

describe 'exec', ->

  scratch = test.scratch @

  it 'should exec', (next) ->
    mecano.exec
      cmd: 'text=yes; echo $text'
      toto: true
    , (err, executed, stdout, stderr) ->
      executed.should.equal 1
      stdout.should.eql 'yes\n'
      next()
  
  it 'should use ssh', (next) ->
    mecano.exec
      ssh: host: 'localhost'
      cmd: 'text=yes; echo $text'
    , (err, executed, stdout, stderr) ->
      stdout.should.eql 'yes\n'
      next()
  
  it 'should stream stdout', (next) ->
    @timeout 10000000
    writer_done = callback_done = null
    # Since version node 0.8, the `writer.end` function 
    # is called after `mecano.exec` callback
    evemit = new EventEmitter
    evemit.writable = true
    evemit.write = (data) ->
      data.should.include 'myself'
    evemit.end = ->
      writer_done = true
      done()
    done = ->
      next() if writer_done and callback_done
    mecano.exec
      cmd: "cat #{__filename}"
      stdout: evemit
    , (err, executed, stdout, stderr) ->
      should.exist stdout
      callback_done = true
      done()
  
  it 'should validate exit code', (next) ->
    # code undefined
    mecano.exec
      cmd: "chown"
    , (err, executed, stdout, stderr) ->
      err.message.should.eql 'Invalid exec code 1'
      # code defined in array
      mecano.exec
        cmd: "chown"
        code: [0, 1]
      , (err, executed, stdout, stderr) ->
        return next err if err
        next()
  
  it 'should honor code skipped', (next) ->
    # code undefined
    mecano.exec
      cmd: "mkdir #{scratch}/my_dir"
      code: 0
      code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return next err if err
      executed.should.eql 1
      mecano.exec
        cmd: "mkdir #{scratch}/my_dir"
        code: 0
        code_skipped: 1
      , (err, executed, stdout, stderr) ->
        return next err if err
        executed.should.eql 0
        next()
  
  it 'should honor conditions', (next) ->
    mecano.exec
      cmd: 'text=yes; echo $text'
      if_exists: __dirname
    , (err, executed, stdout, stderr) ->
      executed.should.eql 1
      stdout.should.eql 'yes\n'
      mecano.exec
        cmd: 'text=yes; echo $text'
        if_exists: "__dirname/toto"
      , (err, executed, stdout, stderr) ->
        executed.should.eql 0
        should.not.exist stdout
        next()


