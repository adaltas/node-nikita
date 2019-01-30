
nikita = require '@nikitajs/core'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.start', ->

  they 'on stopped container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
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
    , (err, {status}) ->
      status.should.be.true() unless err
    .docker.rm
      container: 'nikita_test_start'
      force: true
    .promise()

  they 'on started container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
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
    , (err, {status}) ->
      status.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_start'
      force: true
    .promise()
