
nikita = require '@nikitajs/engine/lib'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.docker

describe 'docker.exec', ->

  they 'simple command', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_exec'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      {status, stdout} = await @docker.exec
        container: 'nikita_test_exec'
        command: 'echo toto'
      status.should.be.true()
      stdout.trim().should.eql 'toto'
      @docker.rm
        container: 'nikita_test_exec'
        force: true

  they 'on stopped container', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_exec'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      @docker.stop
        container: 'nikita_test_exec'
      @docker.exec
        container: 'nikita_test_exec'
        command: 'echo toto'
      .should.be.rejectedWith  /Container [a-z0-9]+ is not running/
      @docker.rm
        container: 'nikita_test_exec'
        force: true

  they 'on non existing container', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.exec
        container: 'nikita_fake_container'
        command: 'echo toto'
      .should.be.rejectedWith 'Error: No such container: nikita_fake_container'

  they 'skip exit code', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_exec'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_exec'
      {status} = await @docker.exec
        container: 'nikita_test_exec'
        command: 'toto'
        code_skipped: 126
      status.should.be.false()
      @docker.rm
        container: 'nikita_test_exec'
        force: true
