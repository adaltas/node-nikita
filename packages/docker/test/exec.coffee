
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.exec', ->
  return unless test.tags.docker

  they 'simple command', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_exec'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      {$status, stdout} = await @docker.exec
        container: 'nikita_test_exec'
        command: 'echo toto'
      $status.should.be.true()
      stdout.trim().should.eql 'toto'
      await @docker.rm
        container: 'nikita_test_exec'
        force: true

  they 'on stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        await @docker.rm
          container: 'nikita_test_exec'
          force: true
        await @docker.tools.service
          image: 'httpd'
          container: 'nikita_test_exec'
        await @docker.stop
          container: 'nikita_test_exec'
        await @docker.exec
          container: 'nikita_test_exec'
          command: 'echo toto'
        throw Error 'Oh no'
      catch err
        err.message.should.match /Container [a-z0-9]+ is not running/
      finally
        @docker.rm
          container: 'nikita_test_exec'
          force: true

  they 'on non existing container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.exec
        container: 'nikita_fake_container'
        command: 'echo toto'
      .should.be.rejectedWith /No such container: nikita_fake_container/

  they 'skip exit code', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_exec'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      {$status} = await @docker.exec
        container: 'nikita_test_exec'
        command: 'toto'
        code: [0, 126]
      $status.should.be.false()
      await @docker.rm
        container: 'nikita_test_exec'
        force: true
