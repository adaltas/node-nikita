
path = require 'path'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'file.upload', ->

  they 'file into a file', (ssh) ->
    return @skip() unless ssh
    nikita
      ssh: ssh
    .file.upload
      source: "#{__filename}"
      target: "#{scratch}/#{path.basename __filename}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/#{path.basename __filename}"
    .file.upload
      source: "#{__filename}"
      target: "#{scratch}/#{path.basename __filename}"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'file into a directory', (ssh) ->
    return @skip() unless ssh
    nikita
      ssh: ssh
    .file.upload
      source: "#{__filename}"
      target: "#{scratch}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/#{path.basename __filename}"
    .file.upload
      source: "#{__filename}"
      target: "#{scratch}"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
