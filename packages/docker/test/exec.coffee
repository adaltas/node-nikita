
nikita = require '@nikitajs/core'
{tags, ssh, scratch, docker} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.exec', ->

  they 'simple command', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .docker.service
      image: 'httpd'
      container: 'nikita_test_exec'
    .docker.exec
      container: 'nikita_test_exec'
      cmd: 'echo toto'
    , (err, {status, stdout}) ->
      status.should.be.true() unless err
      stdout.trim().should.eql 'toto' unless err
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .promise()

  they 'on stopped container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
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
    , (err) ->
      err.message.should.match /Container [a-z0-9]+ is not running/
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .promise()

  they 'on non existing container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.exec
      container: 'nikita_fake_container'
      cmd: 'echo toto'
      relax: true
    , (err) ->
      err.message.should.eql 'Error: No such container: nikita_fake_container'
    .promise()

  they 'skip exit code', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
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
    , (err, {status}) ->
      status.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_exec'
      force: true
    .promise()
