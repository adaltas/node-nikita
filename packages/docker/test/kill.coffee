
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.kill', ->
  return unless test.tags.docker

  they 'running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_kill'
        force: true
      await @docker.tools.service
        image: 'httpd'
        port: '499:80'
        container: 'nikita_test_kill'
      {$status} = await @docker.kill
        container: 'nikita_test_kill'
      $status.should.be.true()

  they 'status not modified (previously killed)', ({ssh}) ->
    @timeout 120000
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_kill'
        force: true
      await @docker.tools.service
        image: 'httpd'
        port: '499:80'
        container: 'nikita_test_kill'
      await @docker.kill
        container: 'nikita_test_kill'
      {$status} = await @docker.kill
        container: 'nikita_test_kill'
      $status.should.be.false()

  they 'status not modified (not living)', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_kill'
      await @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        rm: false
        name: 'nikita_test_kill'
      {$status} = await @docker.kill
        container: 'nikita_test_kill'
      $status.should.be.false()
      await @docker.rm
        container: 'nikita_test_kill'
