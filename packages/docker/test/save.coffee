
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.save', ->
  return unless test.tags.docker

  they 'saves a simple image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.build
        image: 'nikita/load_test'
        content: "FROM alpine\nCMD ['echo \"hello build from text\"']"
      {$status} = await @docker.save
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/nikita_saved.tar"
      $status.should.be.true()

  they.skip 'status not modified', ({ssh}) ->
    # For now, there are no mechanism to compare the checksum between an old and a new target
    nikita
      $ssh: ssh
      docker: test.docker
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.build
        image: 'nikita/load_test'
        content: "FROM alpine\nCMD ['echo \"hello build from text\"']"
      await @docker.save
        debug: true
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/nikita_saved.tar"
      {$status} = await @docker.save
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/nikita_saved.tar"
      $status.should.be.false()
