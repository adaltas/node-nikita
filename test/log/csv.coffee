
fs = require 'fs'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log.csv', ->
  
  scratch = test.scratch @
  
  they 'write string', (ssh, next) ->
    nikita
      ssh: ssh
    .log.csv basedir: scratch
    .call (options) ->
      options.log 'ok'
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      setTimeout ->
        fs.readFile "#{scratch}/localhost.log", 'utf8', (err, content) ->
          content.should.eql 'text,INFO,"ok",\n' unless err
          next err
      , 100
  
