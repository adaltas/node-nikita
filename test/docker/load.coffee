should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker load', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'

# timestamp ensures that hash of the built image will be unique and
# image checksum is also unique

  they 'loads simple image', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
    .remove
      destination: "#{source}/mecano_load.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{source}/mecano_load.tar"
      machine: machine
    .docker_rmi
      machine: machine
      image: 'mecano/load_test:latest'
    .docker_load
      image: 'mecano/load_test:latest'
      machine: machine
      input: "#{source}/mecano_load.tar"
    , (err, loaded, stdout, stderr) ->
      loaded.should.be.true()
      mecano
        ssh: ssh
      .docker_rmi
        machine: machine
        image: 'mecano/load_test:latest'
      .then next

  they 'not loading if checksum', (ssh, next) ->
    mecano
      ssh: ssh
    .remove
      destination: "#{source}/mecano_load.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
      machine: machine
    , (err, execute, stdout, stderr, checksum) ->
      mecano
        ssh: ssh
      .docker_save
        image: 'mecano/load_test:latest'
        output: "#{source}/mecano_load.tar"
        machine: machine
      .docker_load
        image: 'mecano/load_test:latest'
        machine: machine
        input: "#{source}/mecano_load.tar"
        checksum: checksum
      , (err, loaded) ->
        loaded.should.be.false()
        next(err)

  they 'status not modified if same image', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
    .remove
      destination: "#{source}/mecano_load.tar"
    .docker_rmi
      machine: machine
      image: 'mecano/load_test:latest'
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{source}/load.tar"
      machine: machine
    .docker_load
      image: 'mecano/mecano_load:latest'
      machine: machine
      input: "#{source}/load.tar"
    .docker_load
      image: 'mecano/mecano_load:latest'
      machine: machine
      input: "#{source}/load.tar"
    , (err, loaded) ->
      loaded.should.be.false()
    .then next
