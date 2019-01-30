
nikita = require '@nikitajs/core'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.pull', ->

  they 'No Image', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rmi
      image: 'alpine'
    .docker.pull
      tag: 'alpine'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Status Not Modified', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rmi
      image: 'alpine'
    .docker.pull
      tag: 'alpine'
    .docker.pull
      tag: 'alpine'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
