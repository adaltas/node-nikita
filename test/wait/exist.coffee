
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'wait exist', ->

  scratch = test.scratch @

  they 'take a single cmd', (ssh, next) ->
    mecano
      ssh: ssh
    .wait_exist
      target: "#{scratch}"
    , (err, status) ->
      status.should.be.false()
    .call ->
      setTimeout ->
        fs.mkdir ssh, "#{scratch}/a_file", -> # ok
      , 100
    .wait_exist
      target: "#{scratch}/a_file"
      interval: 60
    , (err, status) ->
      status.should.be.true()
    .then next
