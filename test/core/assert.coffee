
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
http = require 'http'

describe 'assert', ->

  scratch = test.scratch @
  
  describe 'status', ->

    they 'false when expected to be false', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, false
      .assert
        status: false
      .promise()

    they 'false when expected to be true throw an error', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, false
      .assert
        status: true
      .next (err) ->
        err.message.should.eql 'Invalid status: expected true, got false'
      .promise()

    they 'true when expected to be true', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, true
      .assert
        status: true
      .promise()

    they 'true when expected to be false throw an error', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, true
      .assert
        status: false
      .next (err) ->
        err.message.should.eql 'Invalid status: expected false, got true'
      .promise()
