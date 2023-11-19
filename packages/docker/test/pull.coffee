
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.pull', ->
  return unless test.tags.docker

  they 'pull image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rmi
        image: 'alpine'
        force: true
      {$status} = await @docker.pull
        image: 'alpine'
      $status.should.be.true()

  they '$status not modified if same image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rmi
        image: 'alpine'
        force: true
      await @docker.pull
        image: 'alpine'
      {$status} = await @docker.pull
        image: 'alpine'
      $status.should.be.false()

  they 'pull specific image tag', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rmi
        image: 'alpine'
        tag: 'edge'
        force: true
      {$status} = await @docker.pull
        image: 'alpine:edge'
      $status.should.be.true()
      {$status} = await @docker.pull
        image: 'alpine'
        tag: 'edge'
      $status.should.be.false()

  they.skip 'pull all tags', ({ssh}) ->
    # skipped because it is too long
    # we need to find an image with a few tags
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rmi
        image: 'alpine'
        force: true
      {$status} = await @docker.pull
        image: 'alpine'
        all: true
      $status.should.be.true()
