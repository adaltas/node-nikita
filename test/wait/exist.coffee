
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'wait.exist', ->

  scratch = test.scratch @

  they 'take a single cmd', (ssh) ->
    nikita
      ssh: ssh
    .wait.exist
      target: "#{scratch}"
    , (err, status) ->
      status.should.be.false()
    .call ->
      setTimeout ->
        nikita(ssh: ssh).fs.mkdir "#{scratch}/a_dir"
      , 100
    .wait.exist
      target: "#{scratch}/a_dir"
      interval: 60
    , (err, status) ->
      status.should.be.true()
    .promise()
