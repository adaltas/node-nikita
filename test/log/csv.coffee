
fs = require 'fs'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log.csv', ->
  
  scratch = test.scratch @
  
  they 'write string', (ssh) ->
    nikita
      ssh: ssh
    .log.csv basedir: scratch
    .call (options) ->
      options.log 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: /^text,INFO,"ok"\n/
      trim: true
      log: false
    .assert status: false
    .promise()

  they 'default options', (ssh) ->
    nikita
      ssh: ssh
      log_csv: basedir: scratch
    .log.csv()
    .call (options) ->
      options.log 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: /^text,INFO,"ok"\n/
      log: false
    .promise()
  
