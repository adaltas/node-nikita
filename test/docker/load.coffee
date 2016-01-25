should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker load', ->

  machine= 'dev'
  config = test.config()
  return if config.docker.disable
  scratch = test.scratch @

# timestamp ensures that hash of the built image will be unique and
# image checksum is also unique

  they 'loads simple image', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      machine: config.docker.machine
    .remove
      destination: "#{scratch}/mecano_load.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{scratch}/mecano_load.tar"
    .docker_rmi
      image: 'mecano/load_test:latest'
    .docker_load
      image: 'mecano/load_test:latest'
      input: "#{scratch}/mecano_load.tar"
    , (err, loaded, stdout, stderr) ->
      loaded.should.be.true() unless err
    .docker_rmi
      image: 'mecano/load_test:latest'
    .then next

  they 'not loading if checksum', (ssh, next) ->
    checksum = null
    mecano
      ssh: ssh
      machine: config.docker.machine
    .remove
      destination: "#{scratch}/mecano_load.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
    , (err, execute, _checksum) ->
      checksum = _checksum
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{scratch}/mecano_load.tar"
    .call ->
      @docker_load
        image: 'mecano/load_test:latest'
        input: "#{scratch}/mecano_load.tar"
        checksum: checksum
      , (err, loaded) ->
        loaded.should.be.false() unless err
    .then next

  they 'status not modified if same image', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      machine: config.docker.machine
    .remove
      destination: "#{scratch}/mecano_load.tar"
    .docker_rmi
      image: 'mecano/load_test:latest'
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{scratch}/load.tar"
    .docker_load
      image: 'mecano/mecano_load:latest'
      input: "#{scratch}/load.tar"
    .docker_load
      image: 'mecano/mecano_load:latest'
      input: "#{scratch}/load.tar"
    , (err, loaded) ->
      loaded.should.be.false()
      next(err)
