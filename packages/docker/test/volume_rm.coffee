
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.volume_rm', ->
  return unless test.tags.docker or test.tags.docker_volume

  describe 'schema', ->

    it 'principal, keyta and password must be provided', ->
      nikita
        docker: test.docker
      , ->
        await @docker.volume_rm {}
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
        docker: test.docker
      , ->
        await @docker.volume_rm
          name: 'my_volume'
        await @docker.volume_create
          name: 'my_volume'
        {$status} = await @docker.volume_rm
          name: 'my_volume'
        $status.should.be.true()
        {$status} = await @docker.volume_rm
          name: 'my_volume'
        $status.should.be.false()
