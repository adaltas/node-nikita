
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.exec', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'simple command', (ssh, next) ->
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
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
      stdout.trim().should.eql 'toto' unless err
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .then next

  they 'on stopped container', (ssh, next) ->
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
    , (err, executed, stdout, stderr) ->
      err.message.should.eql 'Container nikita_test_exec is not running'
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .then next

  they 'on non existing container', (ssh, next) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.exec
      container: 'nikita_fake_container'
      cmd: 'echo toto'
      relax: true
    , (err, executed, stdout, stderr) ->
      err.message.should.eql 'No such container: nikita_fake_container'
    .then next

  they 'skip exit code', (ssh, next) ->
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
    , (err, executed, stdout, stderr) ->
      executed.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .then next
