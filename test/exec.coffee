
assert = require 'assert'
fs = require 'fs'
path = require 'path'
mecano = require '../'

module.exports = 
    'option # cmd': (next) ->
        mecano.exec
            cmd: 'text=yes; echo $text'
        , (err, executed, stdout, stderr) ->
            assert.eql stdout, 'yes\n'
            next()
    'option # host': (next) ->
        mecano.exec
            host: 'localhost'
            cmd: 'text=yes; echo $text'
        , (err, executed, stdout, stderr) ->
            assert.eql stdout, 'yes\n'
            next()


