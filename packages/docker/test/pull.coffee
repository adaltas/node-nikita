
nikita = require '@nikitajs/engine/lib'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.docker

describe 'docker.pull', ->

  they 'No Image', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'alpine'
      {status} = await @docker.pull
        tag: 'alpine'
      status.should.be.true()

  they 'Status Not Modified', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rmi
        image: 'alpine'
      @docker.pull
        tag: 'alpine'
      {status} = await @docker.pull
        tag: 'alpine'
      status.should.be.false()
