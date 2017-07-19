
nikita = require '../../src'
misc = require '../../src/misc'
path = require 'path'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file.upload', ->

  scratch = test.scratch @

  they 'file into a file', (ssh) ->
      return @skip() unless ssh
      nikita
        ssh: ssh
      .file.upload
        source: "#{__filename}"
        target: "#{scratch}/#{path.basename __filename}"
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        fs.stat null, "#{scratch}/#{path.basename __filename}", (err, exist) ->
          exist.isFile().should.be.true() unless err
          callback err
      .file.upload
        source: "#{__filename}"
        target: "#{scratch}/#{path.basename __filename}"
      , (err, status) ->
        status.should.be.false() unless err
      .promise()

    they 'file into a directory', (ssh) ->
        return @skip() unless ssh
        nikita
          ssh: ssh
        .file.upload
          source: "#{__filename}"
          target: "#{scratch}"
        , (err, status) ->
          status.should.be.true() unless err
        .call (_, callback) ->
          fs.stat null, "#{scratch}/#{path.basename __filename}", (err, exist) ->
            exist.isFile().should.be.true() unless err
            callback err
        .file.upload
          source: "#{__filename}"
          target: "#{scratch}"
        , (err, status) ->
          status.should.be.false() unless err
        .promise()
