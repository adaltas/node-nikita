
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.exec', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'simple command', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .docker.service
      image: 'httpd'
      container: 'nikita_test_exec'
    .docker.exec
      container: 'nikita_test_exec'
      cmd: 'echo toto'
    , (err, status, stdout, stderr) ->
      status.should.be.true() unless err
      stdout.trim().should.eql 'toto' unless err
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .promise()

  they 'on stopped container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .docker.service
      image: 'httpd'
      container: 'nikita_test_exec'
    .docker.stop
      container: 'nikita_test_exec'
    .docker.exec
      container: 'nikita_test_exec'
      cmd: 'echo toto'
      relax: true
    , (err, status, stdout, stderr) ->
      err.message.should.match /Container [a-z0-9]+ is not running/
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .promise()

  they 'on non existing container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.exec
      container: 'nikita_fake_container'
      cmd: 'echo toto'
      relax: true
    , (err, status, stdout, stderr) ->
      err.message.should.eql 'Error: No such container: nikita_fake_container'
    .promise()

  they 'skip exit code', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .docker.service
      image: 'httpd'
      container: 'nikita_test_exec'
    .docker.exec
      container: 'nikita_test_exec'
      cmd: 'toto'
      code_skipped: 126
    , (err, status, stdout, stderr) ->
      status.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .promise()
