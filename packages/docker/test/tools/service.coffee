
nikita = require '@nikitajs/engine/lib'
{tags, config, docker} = require '../test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.tools.service', ->
  
  describe 'schema', ->
    
    they 'honors docker.run', ({ssh}) ->
      nikita
        ssh: ssh
        docker: docker
      .docker.tools.service
        image: 'httpd'
        name: false
        port: '499:80'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          
    they 'overwrite default', ({ssh}) ->
      nikita
        ssh: ssh
        docker: docker
      .docker.tools.service
        image: 'httpd'
        name: 'nikita_test_unique'
        port: '499:80'
        handler: ({config}) ->
          config.detach.should.be.true()
          config.rm.should.be.false()

  they 'simple service', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_test_unique'
      @docker.tools.service
        image: 'httpd'
        name: 'nikita_test_unique'
        port: '499:80'
      # .wait_connect
      #   port: 499
      #   host: ipadress of docker, docker-machine...
      @docker.rm
        force: true
        container: 'nikita_test_unique'

  they 'invalid options', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.tools.service
        image: 'httpd'
        port: '499:80'
      .should.be.rejectedWith
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `docker.tools.service`:'
          '#/required config should have required property \'container\'.'
        ].join ' '
      @docker.tools.service
        name: 'toto'
        port: '499:80'
      .should.be.rejectedWith
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `docker.tools.service`:'
          '#/required config should have required property \'image\'.'
        ].join ' '

  they 'status not modified', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        force: true
        container: 'nikita_test'
      @docker.tools.service
        name: 'nikita_test'
        image: 'httpd'
        port: '499:80'
      {status} = await @docker.tools.service
        name: 'nikita_test'
        image: 'httpd'
        port: '499:80'
      status.should.be.false()
      @docker.rm
        force: true
        container: 'nikita_test'
