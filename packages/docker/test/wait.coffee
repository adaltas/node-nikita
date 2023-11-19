
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.wait', ->
  return unless test.tags.docker or test.tags.docker_volume

  they 'container already started', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_wait'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_wait'
      setTimeout =>
        @docker.stop
          container: 'nikita_test_wait'
      , 50
      {$status} = await nikita
        $ssh: ssh
        docker: test.docker
      .docker.wait
        container: 'nikita_test_wait'
      $status.should.be.true()
