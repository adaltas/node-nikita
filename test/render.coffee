
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
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
  
  it 'doesnt increment if destination is same than generated content', (next) ->
    destination = "#{scratch}/render.eco"
    mecano.render
      source: "#{__dirname}/../resources/render.eco"
      destination: destination
      context: who: 'you'
    , (err, rendered) ->
      should.not.exist err
      rendered.should.eql 1
      mecano.render
        source: "#{__dirname}/../resources/render.eco"
        destination: destination
        context: who: 'you'
      , (err, rendered) ->
        should.not.exist err
        rendered.should.eql 0
        next()
  
  it 'complain if source doesnt exist', (next) -> 
    mecano.render
      source: "oups"
      destination: "#{scratch}/render.eco"
    , (err, rendered) ->
      err.message.should.eql 'Invalid source, got "oups"'
      next()
  
  it 'accept destination as a callback', (next) ->
    content = null
    mecano.render
      source: "#{__dirname}/../resources/render.eco"
      destination: (c) ->
        content = c
      context: who: 'you'
    , (err, rendered) ->
      content.should.eql 'Hello you'
      next()



