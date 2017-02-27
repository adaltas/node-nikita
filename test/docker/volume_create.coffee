# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker.run
# as a conseauence docker.run should not docker an other command from docker family
# For this purpos ip, and clean are used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker volume create', ->

  config = test.config()
  return if config.disable_docker
  return if config.disable_docker_volume
  scratch = test.scratch @

  they 'a named volume', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.volume_rm
      name: 'my_volume'
      relax: true
    .docker.volume_create
      name: 'my_volume'
    , (err, status) ->
      status.should.be.true() unless err
    .docker.volume_create
      name: 'my_volume'
    , (err, status) ->
      status.should.be.false() unless err
    .docker.volume_rm
      name: 'my_volume'
    .then next
