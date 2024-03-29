
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'docker.load', ->
  return unless test.tags.docker

  # timestamp ensures that hash of the built image will be unique and
  # image checksum is also unique

  they 'loads simple image', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.build
        image: 'nikita/load_test'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
      await @docker.save
        image: 'nikita/load_test'
        tag: 'latest'
        output: "#{tmpdir}/nikita_load.tar"
      await @docker.rmi
        image: 'nikita/load_test'
      {$status} = await @docker.load
        input: "#{tmpdir}/nikita_load.tar"
      $status.should.be.true()
      await @docker.rmi
        image: 'nikita/load_test'

  they 'not loading if checksum match existing image', ({ssh}) ->
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {image_id} = await @docker.build
        image: 'nikita/load_test'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
      await @docker.save
        image: 'nikita/load_test'
        tag: 'latest'
        output: "#{tmpdir}/nikita_load.tar"
      {$status} = await @docker.load
        input: "#{tmpdir}/nikita_load.tar"
        checksum: image_id
      $status.should.be.false()

  they 'status not modified if same image', ({ssh}) ->
    @timeout 30000
    nikita
      $ssh: ssh
      docker: test.docker
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @docker.rmi
        image: 'nikita/load_test:latest'
      await @docker.build
        image: 'nikita/load_test'
        tag: 'latest'
        content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
      await @docker.save
        image: 'nikita/load_test:latest'
        output: "#{tmpdir}/load.tar"
      await @docker.load
        input: "#{tmpdir}/load.tar"
      {$status} = await @docker.load
        input: "#{tmpdir}/load.tar"
      $status.should.be.false()
