
# Test the internal docker.exec function which execute a docker command

should = require 'should'
docker = require '../../src/misc/docker'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'docker exec', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'

  # they 'not valid docker command', (ssh, next) ->
  #   docker.exec ' help not_a_command ', {  ssh: ssh, machine: machine }, null
  #   , (err, executed) ->
  #     if executed.should.be.false() then next() else next(err)
  #
  # they 'valid docker command', (ssh, next) ->
  #   docker.exec ' help ps  ', {  ssh: ssh, machine: machine }, null
  #   , (err, executed) ->
  #     if executed.should.be.true() then next() else next(err)
  #
  # they 'ignore exit code 1 option', (ssh, next) ->
  #   docker.exec ' rm -f \'not_existing_container\' ', {  ssh: ssh, machine: machine }, true
  #   , (err, executed) ->
  #     if executed.should.be.false() then next() else next(err)
