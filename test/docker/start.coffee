
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker start', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_rm
      container: 'mecano_test_start'
      force: true
    .docker_service
      image: 'httpd'
      name: 'mecano_test_start'
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
      docker: config.docker
    .docker_rm
      container: 'mecano_test_start'
      force: true
    .docker_service
      image: 'httpd'
      name: 'mecano_test_start'
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
