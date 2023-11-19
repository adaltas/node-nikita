
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.stop', ->
  return unless test.tags.docker

  they 'on running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_stop'
      {$status} = await @docker.stop
        container: 'nikita_test_stop'
      $status.should.be.true()
      await @docker.rm
        container: 'nikita_test_stop'
        force: true

  they 'on stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_stop'
      await @docker.stop
        container: 'nikita_test_stop'
      {$status} = await @docker.stop
        container: 'nikita_test_stop'
      $status.should.be.false()
      await @docker.rm
        container: 'nikita_test_stop'
        force: true
