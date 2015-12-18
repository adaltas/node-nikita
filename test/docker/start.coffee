
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
    .docker_rm
      container: 'mecano_test_start'
      force: true
      machine: config.docker.machine
    .docker_run
      image: 'httpd'
      name: 'mecano_test_start'
      service: true
      machine: config.docker.machine
    .docker_stop
      container: 'mecano_test_start'
      machine: config.docker.machine
    .docker_start
      container: 'mecano_test_start'
      machine: config.docker.machine
    , (err, started) ->
      return err if err
      started.should.be.true()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_start'
        force: true
        machine: config.docker.machine
      .then next

  they 'on started container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_start'
      force: true
      machine: config.docker.machine
    .docker_run
      image: 'httpd'
      name: 'mecano_test_start'
      service: true
      machine: config.docker.machine
    .docker_stop
      container: 'mecano_test_start'
      machine: config.docker.machine
    .docker_start
      container: 'mecano_test_start'
      machine: config.docker.machine
    .docker_start
      container: 'mecano_test_start'
      machine: config.docker.machine
    , (err, started) ->
      return err if err
      started.should.be.false()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_start'
        force: true
        machine: config.docker.machine
      .then next
