
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.tools.status', ->
  return unless test.tags.docker

  they 'on stopped  container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_status'
        force: true
      await @docker.run
        command: "/bin/echo 'test'"
        image: 'alpine'
        rm: false
        name: 'nikita_status'
      {$status} = await @docker.tools.status
        container: 'nikita_status'
      $status.should.be.false()
      await @docker.rm
        container: 'nikita_status'
        force: true

  they 'on running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_status'
        force: true
      await @docker.tools.service
        image: 'httpd'
        port: [ '500:80' ]
        container: 'nikita_status'
      {$status} = await @docker.tools.status
        container: 'nikita_status'
      $status.should.be.true()
      await @docker.rm
        container: 'nikita_status'
        force: true
