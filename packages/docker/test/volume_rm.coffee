
nikita = require '@nikitajs/core'
{tags, ssh, scratch, docker} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.docker or tags.docker_volume

describe 'docker.volume_rm', ->

  they 'a named volume', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.volume_rm
      name: 'my_volume'
      relax: true
    .docker.volume_create
      name: 'my_volume'
    .docker.volume_rm
      name: 'my_volume'
    , (err, {status}) ->
      status.should.be.true() unless err
    .docker.volume_rm
      name: 'my_volume'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
