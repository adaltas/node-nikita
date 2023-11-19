
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.rm', ->
  return unless test.tags.docker

  they 'status', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        force: true
        container: 'nikita_rm'
      await @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        name: 'nikita_rm'
        rm: false
      {$status} = await @docker.rm
        container: 'nikita_rm'
      $status.should.be.true()
      {$status} = await @docker.rm
        container: 'nikita_rm'
      $status.should.be.false()

  they 'remove live container (no force)', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        await @docker.rm
          container: 'nikita_rm'
          force: true
        await @docker.tools.service
          image: 'httpd'
          port: '499:80'
          container: 'nikita_rm'
        await @docker.rm
          container: 'nikita_rm'
        throw Error 'Oh no'
      catch err
        # Error response from daemon: You cannot remove a running container XXXXX. Stop the container before attempting removal or force remove
        # Container must be stopped to be removed without force
        err.message.should.match /(You cannot remove a running container)|(Container must be stopped)/
      finally
        await @docker.stop
          container: 'nikita_rm'
        await @docker.rm
          container: 'nikita_rm'

  they 'remove live container (with force)', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_rm'
        force: true
      await @docker.tools.service
        image: 'httpd'
        port: '499:80'
        container: 'nikita_rm'
      {$status} = await @docker.rm
        container: 'nikita_rm'
        force: true
      $status.should.be.true()
