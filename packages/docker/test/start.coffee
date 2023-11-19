
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.start', ->
  return unless test.tags.docker

  they 'on stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_start'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_start'
      await @docker.stop
        container: 'nikita_test_start'
      {$status} = await @docker.start
        container: 'nikita_test_start'
      $status.should.be.true()
      await @docker.rm
        container: 'nikita_test_start'
        force: true

  they 'on started container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_start'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_start'
      await @docker.stop
        container: 'nikita_test_start'
      await @docker.start
        container: 'nikita_test_start'
      {$status} = await @docker.start
        container: 'nikita_test_start'
      $status.should.be.false()
      await @docker.rm
        container: 'nikita_test_start'
        force: true
