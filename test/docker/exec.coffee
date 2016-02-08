
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker exec', ->

  config = test.config()
  return if config.docker.disable
  scratch = test.scratch @

  they 'simple command', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_service
      image: 'httpd'
      container: 'mecano_test_exec'
    .docker_exec
      container: 'mecano_test_exec'
      cmd: 'echo toto'
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
      stdout.trim().should.eql 'toto'
    .docker_rm
      container: 'mecano_test_exec'
      force: true
    .then next

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_service
      image: 'httpd'
      container: 'mecano_test_exec'
    .docker_stop container: 'mecano_test_exec'
    .docker_exec
      container: 'mecano_test_exec'
      cmd: 'echo toto'
      relax: true
    , (err, executed, stdout, stderr) ->
      err.message.should.eql 'Container mecano_test_exec is not running'
    .docker_rm
      container: 'mecano_test_exec'
    .then next

  they 'on non existing container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_exec
      container: 'mecano_fake_container'
      cmd: 'echo toto'
      relax: true
    , (err, executed, stdout, stderr) ->
      err.message.should.eql 'No such container: mecano_fake_container'
    .then next
