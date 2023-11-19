
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.tools.checksum', ->
  return unless test.tags.docker

  they 'checksum on existing repository', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      await @docker.rmi
        image: 'nikita/checksum'
      {image_id} = await @docker.build
        image: 'nikita/checksum'
        content: "FROM scratch\nCMD ['echo \"hello build from text #{Date.now()}\"']"
      {checksum} = await @docker.tools.checksum
        image: 'nikita/checksum'
        tag: 'latest'
      checksum.should.startWith "sha256:#{image_id}"
      await @docker.rmi
        image: 'nikita/checksum'

  they 'checksum on not existing repository', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
    , ->
      {checksum} = await @docker.tools.checksum
        image: 'nikita/invalid_checksum'
        tag: 'latest'
      (checksum is undefined).should.be.true()
