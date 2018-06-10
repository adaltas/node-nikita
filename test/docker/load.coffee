
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.load', ->

  machine= 'dev'
  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

# timestamp ensures that hash of the built image will be unique and
# image checksum is also unique

  they 'loads simple image', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: config.docker
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
    , (err, loaded, stdout, stderr) ->
      loaded.should.be.true() unless err
    .docker.rmi
      image: 'nikita/load_test'
    .promise()

  they 'not loading if checksum', (ssh) ->
    checksum = null
    nikita
      ssh: ssh
      docker: config.docker
    .system.remove
      target: "#{scratch}/nikita_load.tar"
    .docker.build
      image: 'nikita/load_test'
      tag: 'latest'
      content: "FROM alpine\nCMD ['echo \"docker.build #{Date.now()}\"']"
    , (err, execute, _checksum) ->
      checksum = _checksum
    .docker.save
      image: 'nikita/load_test'
      tag: 'latest'
      output: "#{scratch}/nikita_load.tar"
    .call ->
      @docker.load
        input: "#{scratch}/nikita_load.tar"
        checksum: checksum
      , (err, loaded) ->
        loaded.should.be.false() unless err
    .promise()

  they 'status not modified if same image', (ssh) ->
    @timeout 30000
    nikita
      ssh: ssh
      docker: config.docker
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
    , (err, loaded) ->
      loaded.should.be.false()
    .promise()
