
{EventEmitter} = require 'events'
should = require 'should'
mecano = require '../'

describe 'exec', ->

    it 'should exec', (next) ->
        await mecano.exec
            cmd: 'text=yes; echo $text'
        , defer err, executed, stdout, stderr
        executed.should.equal 1
        stdout.should.eql 'yes\n'
        next()
    
    it 'should use ssh', (next) ->
        await mecano.exec
            host: 'localhost'
            cmd: 'text=yes; echo $text'
        , defer err, executed, stdout, stderr
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
        await mecano.exec
            cmd: "cat #{__filename}"
            stdout: evemit
        , defer err, executed, stdout, stderr
        should.not.exist stdout
        callback_done = true
        done()
    
    it 'should validate exit code', (next) ->
        # code undefined
        await mecano.exec
            cmd: "chown"
        , defer err, executed, stdout, stderr
        err.message.should.eql 'Invalid exec code 1'
        # code defined in array
        await mecano.exec
            cmd: "chown"
            code: [0, 1]
        , defer err, executed, stdout, stderr
        should.not.exist err
        next()
    
    it 'should honore conditions', (next) ->
        await mecano.exec
            cmd: 'text=yes; echo $text'
            if_exists: __dirname
        , defer err, executed, stdout, stderr
        executed.should.eql 1
        stdout.should.eql 'yes\n'
        await mecano.exec
            cmd: 'text=yes; echo $text'
            if_exists: "__dirname/toto"
        , defer err, executed, stdout, stderr
        executed.should.eql 0
        should.not.exist stdout
        next()


