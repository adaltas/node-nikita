
fs = require 'fs'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'log.csv', ->
  
  they 'write string', ({ssh}) ->
    nikita
      ssh: ssh
    .log.csv basedir: scratch
    .call ->
      @log 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: /^text,INFO,"ok"\n/
      trim: true
      log: false
    .assert status: false
    .promise()

  they 'default options', ({ssh}) ->
    nikita
      ssh: ssh
      log_csv: basedir: scratch
    .log.csv()
    .call ->
      @log 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: /^text,INFO,"ok"\n/
      log: false
    .promise()
  
