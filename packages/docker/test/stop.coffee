
nikita = require '@nikita/core'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.stop', ->

  they 'on running container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.service
      image: 'httpd'
      name: 'nikita_test_stop'
    .docker.stop
      container: 'nikita_test_stop'
    , (err, {status}) ->
      status.should.be.true()
    .docker.rm
      container: 'nikita_test_stop'
      force: true
    .promise()

  they 'on stopped container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.service
      image: 'httpd'
      name: 'nikita_test_stop'
    .docker.stop
      container: 'nikita_test_stop'
    .docker.stop
      container: 'nikita_test_stop'
    , (err, {status}) ->
      status.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_stop'
      force: true
    .promise()
