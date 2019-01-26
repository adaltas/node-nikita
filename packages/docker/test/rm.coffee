
nikita = require '@nikita/core'
{tags, ssh, scratch, docker} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.rm', ->

  they 'remove stopped container', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      force: true
      container: 'nikita_rm'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'nikita_rm'
      rm: false
    .docker.rm
      container: 'nikita_rm'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'remove live container (no force)', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_rm'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'nikita_rm'
    .docker.rm
      container: 'nikita_rm'
      relax: true
    , (err) ->
      err.message.should.eql 'Container must be stopped to be removed without force'
    .docker.stop
      container: 'nikita_rm'
    .docker.rm
      container: 'nikita_rm'
    .promise()

  they 'remove live container (with force)', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_rm'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'nikita_rm'
    .docker.rm
      container: 'nikita_rm'
      force: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
