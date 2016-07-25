
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'assert', ->

  scratch = test.scratch @

  they 'status false is false', (ssh, next) ->
    mecano
    .call (_, callback) ->
      callback null, false
    .assert
      status: false
    .then next

  they 'status false is true', (ssh, next) ->
    mecano
    .call (_, callback) ->
      callback null, false
    .assert
      status: true
    .then (err) ->
      err.message.should.eql 'Invalid status: expected true, got false'
      next()

  they 'status true is true', (ssh, next) ->
    mecano
    .call (_, callback) ->
      callback null, true
    .assert
      status: true
    .then next

  they 'status true is false', (ssh, next) ->
    mecano
    .call (_, callback) ->
      callback null, true
    .assert
      status: false
    .then (err) ->
      err.message.should.eql 'Invalid status: expected false, got true'
      next()
