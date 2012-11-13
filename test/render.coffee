
fs = require 'fs'
should = require 'should'
mecano = require '../'
test = require './test'

describe 'render', ->

  scratch = test.scratch @
  
  it 'should use `content`', (next) ->
    destination = "#{scratch}/render.eco"
    mecano.render
      content: 'Hello <%- @who %>'
      destination: destination
      context: who: 'you'
    , (err, rendered) ->
      should.not.exist err
      rendered.should.eql 1
      fs.readFile destination, 'ascii', (err, content) ->
        content.should.eql 'Hello you'
        next()
  
  it 'should use `source`', (next) ->
    destination = "#{scratch}/render.eco"
    mecano.render
      source: "#{__dirname}/../resources/render.eco"
      destination: destination
      context: who: 'you'
    , (err, rendered) ->
      should.not.exist err
      rendered.should.eql 1
      fs.readFile destination, 'ascii', (err, content) ->
        content.should.eql 'Hello you'
        next()
  
  it 'should be unhappy', (next) ->
    destination = "#{scratch}/render.eco"
    mecano.render
      source: "oups"
      destination: destination
    , (err, rendered) ->
      err.message.should.eql 'Invalid source, got "oups"'
      next()



