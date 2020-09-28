
nikita = require '@nikitajs/engine/src'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.docker

describe 'docker.inspect', ->

  they 'one running container', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm
        container: 'nikita_test_inspect'
        force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_inspect'
      {info} = await @docker.inspect
        container: 'nikita_test_inspect'
      info.Name.should.eql '/nikita_test_inspect'
      @docker.rm
        container: 'nikita_test_inspect'
        force: true

  they.skip 'two running containers', ({ssh}) ->
    # TODO: array of containers not yet implemented
    # the inspect command shall be ready but not the exists command
    nikita
      ssh: ssh
      docker: docker
    , ->
      @docker.rm [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], force: true
      @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_inspect'
      {info} = await @docker.inspect
        container: [
          'nikita_test_inspect_1'
          'nikita_test_inspect_2'
        ]
      names = info.map (i) -> i.Name
      names.should.eql [
        '/nikita_test_inspect_1'
        '/nikita_test_inspect_2'
      ]
      @docker.rm [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], force: true
