
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.tools.service', ->
  return unless test.tags.docker
  
  describe 'schema', ->
    
    they 'honors docker.run', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      .docker.tools.service
        image: 'httpd'
        container: 'nikita_test_unique'
        pid: [key: true] # docker.run action define type string
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          
    they 'overwrite default', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      .docker.tools.service
        image: 'httpd'
        container: 'nikita_test_unique'
        port: '499:80'
      , ({config}) ->
        config.detach.should.be.true()
        config.rm.should.be.false()

    they 'simple service', ({ssh}) ->
      nikita
        $ssh: ssh
        docker: test.docker
      , ->
        await @docker.rm
          force: true
          container: 'nikita_test_unique'
        await @docker.tools.service
          image: 'httpd'
          container: 'nikita_test_unique'
          port: '499:80'
        # .wait_connect
        #   port: 499
        #   host: ipadress of docker, docker-machine...
        await @docker.rm
          force: true
          container: 'nikita_test_unique'

    it 'config.container required', ->
      nikita.docker.tools.service
        image: 'httpd'
        port: '499:80'
      .should.be.rejectedWith
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `docker.tools.service`:'
          '#/required config must have required property \'container\'.'
        ].join ' '

    it 'config.image required', ->
      nikita.docker.tools.service
        container: 'toto'
        port: '499:80'
      .should.be.rejectedWith
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `docker.tools.service`:'
          '#/required config must have required property \'image\'.'
        ].join ' '

  they 'status not modified', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        force: true
        container: 'nikita_test'
      await @docker.tools.service
        container: 'nikita_test'
        image: 'httpd'
        port: '499:80'
      {$status} = await @docker.tools.service
        container: 'nikita_test'
        image: 'httpd'
        port: '499:80'
      $status.should.be.false()
      await @docker.rm
        force: true
        container: 'nikita_test'
