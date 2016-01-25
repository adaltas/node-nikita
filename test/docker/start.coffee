
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker start', ->

  config = test.config()
  return if config.docker.disable
  scratch = test.scratch @

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_test_start'
      force: true
    .docker_run
      image: 'httpd'
      name: 'mecano_test_start'
      service: true
    .docker_stop
      container: 'mecano_test_start'
    .docker_start
      container: 'mecano_test_start'
    , (err, started) ->
      started.should.be.true() unless err
    .docker_rm
      container: 'mecano_test_start'
      force: true
    .then next

  they 'on started container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_test_start'
      force: true
    .docker_run
      image: 'httpd'
      name: 'mecano_test_start'
      service: true
    .docker_stop
      container: 'mecano_test_start'
    .docker_start
      container: 'mecano_test_start'
    .docker_start
      container: 'mecano_test_start'
    , (err, started) ->
      started.should.be.false() unless err
    .docker_rm
      container: 'mecano_test_start'
      force: true
    .then next
