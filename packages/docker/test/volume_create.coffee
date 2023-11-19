
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.volume_create', ->
  return unless test.tags.docker or test.tags.docker_volume

  describe 'schema', ->

    it 'cast label string to array', ->
      (
        await nikita
          docker: test.docker
        .docker.volume_create
            label: 'test'
          , ({config: {label}}) => label
      )
      .should.eql ['test']

    it 'cast opt string to array', ->
      (
        await nikita
          docker: test.docker
        .docker.volume_create
            opt: 'test'
          , ({config: {opt}}) => opt
      )
      .should.eql ['test']

  describe 'action', ->

    they 'a named volume', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      , ->
        await @docker.volume_rm
          name: 'my_volume'
        {$status} = await @docker.volume_create
          name: 'my_volume'
        $status.should.be.true()
        {$status} = await @docker.volume_create
          name: 'my_volume'
        $status.should.be.false()
        await @docker.volume_rm
          name: 'my_volume'
