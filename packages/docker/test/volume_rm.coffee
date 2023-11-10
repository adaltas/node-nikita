
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker or tags.docker_volume

describe 'docker.volume_rm', ->

  describe 'schema', ->

    it 'principal, keyta and password must be provided', ->
      nikita
        docker: docker
      , ->
        @docker.volume_rm {}
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'one error was found in the configuration of action `docker.volume_rm`:'
            '#/required config must have required property \'name\'.'
          ].join ' '

  describe 'action', ->

    they 'a named volume', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: docker
      , ->
        @docker.volume_rm
          name: 'my_volume'
        @docker.volume_create
          name: 'my_volume'
        {$status} = await @docker.volume_rm
          name: 'my_volume'
        $status.should.be.true()
        {$status} = await @docker.volume_rm
          name: 'my_volume'
        $status.should.be.false()
