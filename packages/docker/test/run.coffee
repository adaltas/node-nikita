
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.run', ->
  return unless test.tags.docker

  they 'option `rm` is `false` by default', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        await @docker.rm 'nikita_test_run_rm_false', force: true
        await @docker.run
          command: "/bin/echo 'test'"
          image: 'alpine'
          container: 'nikita_test_run_rm_false'
        {names} = await @docker.ps all: true
        names.should.containEql 'nikita_test_run_rm_false'
      finally
        await @docker.rm 'nikita_test_run_rm_false', force: true
  
  they 'option `rm` is `false`', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        await @docker.rm 'nikita_test_run_rm_true', force: true
        {$status, stdout} = await @docker.run
          command: "/bin/echo 'test'"
          image: 'alpine'
          rm: true
        {names} = await @docker.ps all: true
        names.should.not.containEql 'nikita_test_run_rm_true'
      finally
        await @docker.rm 'nikita_test_run_rm_true', force: true

  they 'output `stdout`', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      try
        {stdout} = await @docker.run
          command: "/bin/echo 'test'"
          image: 'alpine'
          container: 'nikita_test_rm'
          rm: true
        stdout.should.match /^test.*/
      finally
        await @docker.rm 'nikita_test_rm', force: true

  they 'unique option from array option', ({ssh}) ->
    @timeout 0
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        container: 'nikita_test_unique'
        force: true
      await @docker.run
        image: 'httpd'
        port: '499:80'
        container: 'nikita_test_unique'
        detach: true
        rm: false
      await @docker.rm
        force: true
        container: 'nikita_test_unique'

  they 'array options', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        force: true
        container: 'nikita_test_array'
      await @docker.run
        image: 'httpd'
        port: [ '500:80', '501:81' ]
        container: 'nikita_test_array'
        detach: true
        rm: false
      await @docker.rm
        force: true
        container: 'nikita_test_array'

  they 'existing container', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        force: true
        container: 'nikita_test'
      await @docker.run
        command: 'echo test'
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      {$status} = await @docker.run
        command: "echo test"
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      $status.should.be.false()
      await @docker.rm
        force: true
        container: 'nikita_test'

  they 'status not modified', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rm
        force: true
        container: 'nikita_test'
      await @docker.run
        command: 'echo test'
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      {$status} = await @docker.run
        command: 'echo test'
        image: 'alpine'
        container: 'nikita_test'
        rm: false
      $status.should.be.false()
      await @docker.rm
        force: true
        container: 'nikita_test'
