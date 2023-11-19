
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.inspect', ->
  return unless test.tags.docker

  they 'one running container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_inspect'
        force: true
      await @docker.tools.service
        image: 'httpd'
        container: 'nikita_test_inspect'
      {info} = await @docker.inspect
        container: 'nikita_test_inspect'
      info.Name.should.eql '/nikita_test_inspect'
      await @docker.rm
        container: 'nikita_test_inspect'
        force: true

  they 'two running containers', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], force: true
      await @docker.tools.service [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], image: 'httpd'
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
      await @docker.rm [
        container: 'nikita_test_inspect_1'
      ,
        container: 'nikita_test_inspect_2'
      ], force: true
