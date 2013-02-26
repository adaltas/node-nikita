
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
connect = require 'superexec/lib/connect'

describe 'write', ->

  scratch = test.scratch @
  
  it 'should write a file', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      fs.readFile "#{scratch}/file", 'ascii', (err, content) ->
        content.should.eql 'Hello'
        next()
  
  it 'doesnt increment if destination is same than generated content', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      mecano.write
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        written.should.eql 0
        next()
  
  it 'doesnt increment if destination is same than generated content', (next) ->
    mecano.write
      content: 'Hello'
      destination: "#{scratch}/file"
    , (err, written) ->
      return next err if err
      mecano.write
        source: "#{scratch}/file"
        destination: "#{scratch}/file_copy"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        fs.readFile "#{scratch}/file", 'ascii', (err, content) ->
          content.should.eql 'Hello'
          next()
  
  it 'work over ssh', (next) ->
    connect host: 'localhost', (err, ssh) ->
      mecano.write
        ssh: ssh
        content: 'Hello'
        destination: "#{scratch}/file"
      , (err, written) ->
        return next err if err
        written.should.eql 1
        mecano.write
          ssh: ssh
          content: 'Hello'
          destination: "#{scratch}/file"
        , (err, written) ->
          return next err if err
          written.should.eql 0
          next()

  it 'can not defined source and content', (next) ->
    mecano.write
      source: 'abc'
      content: 'abc'
      destination: 'abc'
    , (err) ->
      err.message.should.eql 'Define either source or content'
      next()


