
nikita = require '@nikitajs/engine/src'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.docker or tags.docker_volume

describe 'docker.wait', ->

  they 'container already started', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_wait'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_wait'
      setTimeout =>
        await @docker.stop
          container: 'nikita_test_wait'
      , 50
      {status} = await nikita.docker.wait
        container: 'nikita_test_wait'
      status.should.be.true()
