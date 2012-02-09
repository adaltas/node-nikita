
{EventEmitter} = require 'events'
assert = require 'assert'
mecano = require '../'

module.exports = 
    'exec # option # cmd': (next) ->
        mecano.exec
            cmd: 'text=yes; echo $text'
        , (err, executed, stdout, stderr) ->
            assert.eql stdout, 'yes\n'
            next()
    'exec # option # host': (next) ->
        mecano.exec
            host: 'localhost'
            cmd: 'text=yes; echo $text'
        , (err, executed, stdout, stderr) ->
            assert.eql stdout, 'yes\n'
            next()
    'exec # option # stdout': (next) ->
        evemit = new EventEmitter
        evemit.on 'data', (data) -> assert.eql stdout, 'yes\n'
        evemit.end = next
        mecano.exec
            host: 'localhost'
            cmd: 'text=yes; echo $text'
            stdout: evemit
        , (err, executed, stdout, stderr) ->
            assert.eql stdout, null


