
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.rmi', ->
  return unless test.tags.docker

  they 'remove image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.build
        image: 'nikita/rmi_test'
        content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      {$status} = await @docker.rmi
        image: 'nikita/rmi_test'
      $status.should.be.true()

  they 'status unmodifed', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.build
        image: 'nikita/rmi_test:latest'
        content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      await @docker.rmi
        image: 'nikita/rmi_test'
      {$status} = await @docker.rmi
        image: 'nikita/rmi_test'
      $status.should.be.false()
