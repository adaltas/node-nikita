
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require './test'
they = require('mocha-they')(config)

return unless tags.docker or tags.docker_volume

describe 'docker.volume_create', ->

  describe 'schema', ->

    it 'cast label string to array', ->
      (
        await nikita
          docker: docker
        .docker.volume_create
            label: 'test'
          , ({config: {label}}) => label
      )
      .should.eql ['test']

    it 'cast opt string to array', ->
      (
        await nikita
          docker: docker
        .docker.volume_create
            opt: 'test'
          , ({config: {opt}}) => opt
      )
      .should.eql ['test']

  describe 'action', ->

    they 'a named volume', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: docker
      , ->
        @docker.volume_rm
          name: 'my_volume'
        {$status} = await @docker.volume_create
          name: 'my_volume'
        $status.should.be.true()
        {$status} = await @docker.volume_create
          name: 'my_volume'
        $status.should.be.false()
        @docker.volume_rm
          name: 'my_volume'
