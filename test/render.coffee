
assert = require 'assert'
fs = require 'fs'
mecano = require '../'

module.exports =

    'option # content': (next) ->
        destination = "#{__dirname}/render.eco"
        mecano.render
            content: 'Hello <%- @who %>'
            destination: destination
            context: { who: 'you' }
        , (err, rendered) ->
            assert.ifError err
            assert.eql rendered, 1
            fs.readFile destination, 'ascii', (err, content) ->
                assert.eql content, 'Hello you'
                next()
    
    'option # source': (next) ->
        destination = "#{__dirname}/render.eco"
        mecano.render
            source: "#{__dirname}/../resources/render.eco"
            destination: destination
            context: { who: 'you' }
        , (err, rendered) ->
            assert.ifError err
            assert.eql rendered, 1
            fs.readFile destination, 'ascii', (err, content) ->
                assert.eql content, 'Hello you'
                next()
    
    'error # invalid source': (next) ->
        mecano.render
            source: "oups"
            destination: "#{__dirname}/render.eco"
        , (err, rendered) ->
            assert.eql err.message, 'Invalid source, got "oups"'
            next()



