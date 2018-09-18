
nikita = require '../../src'
{tags, ssh, scratch, docker} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.load', ->

# timestamp ensures that hash of the built image will be unique and
# image checksum is also unique

  they 'loads simple image', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: docker
    .system.remove
      target: "#{scratch}/nikita_load.tar"
    .docker.build
      image: 'nikita/load_test'
      tag: 'latest'
      content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
    .docker.save
      image: 'nikita/load_test'
      tag: 'latest'
      output: "#{scratch}/nikita_load.tar"
    .docker.rmi
      image: 'nikita/load_test'
    .docker.load
      image: 'nikita/load_test'
      tag: 'latest'
      input: "#{scratch}/nikita_load.tar"
    , (err, {status}) ->
      status.should.be.true() unless err
    .docker.rmi
      image: 'nikita/load_test'
    .promise()

  they 'not loading if checksum', (ssh) ->
    expect_checksum = null
    nikita
      ssh: ssh
      docker: docker
    .system.remove
      target: "#{scratch}/nikita_load.tar"
    .docker.build
      image: 'nikita/load_test'
      tag: 'latest'
      content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
    , (err, {status, checksum}) ->
      expect_checksum = checksum
    .docker.save
      image: 'nikita/load_test'
      tag: 'latest'
      output: "#{scratch}/nikita_load.tar"
    .call ->
      @docker.load
        input: "#{scratch}/nikita_load.tar"
        checksum: expect_checksum
      , (err, {status}) ->
        status.should.be.false() unless err
    .promise()

  they 'status not modified if same image', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: docker
    .system.remove
      target: "#{scratch}/nikita_load.tar"
    .docker.rmi
      image: 'nikita/load_test:latest'
    .docker.build
      image: 'nikita/load_test'
      tag: 'latest'
      content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
    .docker.save
      image: 'nikita/load_test:latest'
      output: "#{scratch}/load.tar"
    .docker.load
      image: 'nikita/nikita_load:latest'
      input: "#{scratch}/load.tar"
    .docker.load
      image: 'nikita/nikita_load:latest'
      input: "#{scratch}/load.tar"
    , (err, {status}) ->
      status.should.be.false()
    .promise()
