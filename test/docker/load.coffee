should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker load', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'


  they 'loads simple image', (ssh, next) ->

    # timestamp ensures that hash of the built image will be unique and
    # image checksum is also unique
    mecano
      ssh: ssh
    .remove
      destination: "#{source}/mecano_load.tar"
    .docker_build
      image: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      destination: "#{source}/mecano_load.tar"
      machine: machine
    .docker_rmi
      machine: machine
      image: 'mecano/load_test:latest'
    .docker_load
      image: 'mecano/load_test:latest'
      machine: machine
      source: "#{source}/mecano_load.tar"
    , (err, loaded) ->
      loaded.should.be.true()
    .then next

  they 'status not modified if same image', (ssh, next) ->
    mecano
      ssh: ssh
    .remove
      destination: "#{source}/mecano_load.tar"
    .docker_build
      image: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"docker_build #{Date.now()}\"']"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      destination: "#{source}/load.tar"
      machine: machine
    .docker_load
      image: 'mecano/mecano_load:latest'
      machine: machine
      source: "#{source}/load.tar"
    .docker_load
      image: 'mecano/mecano_load:latest'
      machine: machine
      source: "#{source}/load.tar"
    , (err, loaded) ->
      loaded.should.be.false()
    .then next
