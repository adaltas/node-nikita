
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'

describe 'write', ->

  scratch = test.scratch @
  
  it 'should write a file', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      should.not.exist err
      written.should.eql 1
      fs.readFile "#{scratch}/file", 'ascii', (err, content) ->
        content.should.eql 'Hello'
        next()
  
  it 'doesnt increment if destination is same than generated content', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      should.not.exist err
      written.should.eql 1
      mecano.write
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        should.not.exist err
        written.should.eql 0
        next()