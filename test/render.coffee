
fs = require 'fs'
should = require 'should'
mecano = require '../'

describe 'render', ->
    
    it 'should use `content`', (next) ->
        destination = "#{__dirname}/render.eco"
        mecano.render
            content: 'Hello <%- @who %>'
            destination: destination
            context: who: 'you'
        , (err, rendered) ->
            should.not.exist err
            rendered.should.eql 1
            fs.readFile destination, 'ascii', (err, content) ->
                content.should.eql 'Hello you'
                mecano.rm destination, next
    
    it 'should use `source`', (next) ->
        destination = "#{__dirname}/render.eco"
        mecano.render
            source: "#{__dirname}/../resources/render.eco"
            destination: destination
            context: who: 'you'
        , (err, rendered) ->
            should.not.exist err
            rendered.should.eql 1
            fs.readFile destination, 'ascii', (err, content) ->
                content.should.eql 'Hello you'
                mecano.rm destination, next
    
    it 'should be unhappy', (next) ->
        destination = "#{__dirname}/render.eco"
        mecano.render
            source: "oups"
            destination: destination
        , (err, rendered) ->
            err.message.should.eql 'Invalid source, got "oups"'
            mecano.rm destination, next



