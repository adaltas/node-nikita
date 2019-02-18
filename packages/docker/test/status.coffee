
nikita = require '@nikitajs/core'
{tags, ssh, scratch, docker} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.docker

describe 'docker.status', ->

  they 'on stopped  container', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_status'
      force: true
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      name: 'nikita_status'
    .docker.status
      container: 'nikita_status'
    , (err, {status}) ->
      status.should.be.false() unless err
    .docker.rm
      container: 'nikita_status'
      force: true
    .promise()

  they 'on running container', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_status'
      force: true
    .docker.service
      image: 'httpd'
      port: [ '500:80' ]
      name: 'nikita_status'
    .docker.status
      container: 'nikita_status'
    , (err, {status}) ->
      status.should.be.true()
    .docker.rm
      container: 'nikita_status'
      force: true
    .promise()
