
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.start', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'on stopped container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_start'
      force: true
    .docker.service
      image: 'httpd'
      name: 'nikita_test_start'
    .docker.stop
      container: 'nikita_test_start'
    .docker.start
      container: 'nikita_test_start'
    , (err, started) ->
      started.should.be.true() unless err
    .docker.rm
      container: 'nikita_test_start'
      force: true
    .promise()

  they 'on started container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_start'
      force: true
    .docker.service
      image: 'httpd'
      name: 'nikita_test_start'
    .docker.stop
      container: 'nikita_test_start'
    .docker.start
      container: 'nikita_test_start'
    .docker.start
      container: 'nikita_test_start'
    , (err, started) ->
      started.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_start'
      force: true
    .promise()
