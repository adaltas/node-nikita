
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.ps', ->
  return unless test.tags.docker

  they 'output `count`, `names`', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        await @docker.run
          command: "sh -c 'while true; do sleep 1000; done'"
          detach: true
          image: 'alpine'
          container: 'nikita_test_ps_1'
        await @docker.run
          command: "sh -c 'while true; do sleep 1000; done'"
          detach: true
          image: 'alpine'
          container: 'nikita_test_ps_2'
        {count, names, containers} = await @docker.ps()
        count.should.eql 2
        names.sort().should.eql ['nikita_test_ps_1', 'nikita_test_ps_2']
      finally
        await @docker.rm 'nikita_test_ps_1', force: true
        await @docker.rm 'nikita_test_ps_2', force: true

  they 'option `all`', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        await @docker.run
          command: "/bin/echo 'test'"
          image: 'alpine'
          container: 'nikita_test_ps_3'
        await @docker.run
          command: "/bin/echo 'test'"
          image: 'alpine'
          container: 'nikita_test_ps_4'
        await @docker.ps
          all: true
        .then ({containers}) ->
          containers.map((c) => c.Names).sort()
        .should.be.resolvedWith ['nikita_test_ps_3', 'nikita_test_ps_4']
      finally
        await @docker.rm 'nikita_test_ps_3'
        await @docker.rm 'nikita_test_ps_4'
  