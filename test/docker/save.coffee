should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker save', ->

  scratch = test.scratch @
  source = "#{scratch}"
  config = test.config()


  they 'saves a simple image', (ssh, next) ->
    mecano
      ssh: ssh
    .remove
      destination:"#{source}/mecano_saved.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      machine: config.docker.machine
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{source}/mecano_saved.tar"
      machine: config.docker.machine
    , (err, saved) ->
      return err if err
      saved.should.be.true()
      mecano
        ssh: ssh
      .remove
        destination:"#{source}/mecano_saved.tar"
      , (err) -> next(err)

  # they 'status not modified', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .remove
  #     destination:"#{source}/mecano_saved.tar"
  #   .docker_build
  #     tag: 'mecano/load_test:latest'
  #     content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
  #     machine: config.docker.machine
  #   .docker_save
  #     image: 'mecano/load_test:latest'
  #     output: "#{source}/mecano_saved.tar"
  #     machine: config.docker.machine
  #   .docker_save
  #     image: 'mecano/load_test:latest'
  #     output: "#{source}/mecano_saved.tar"
  #     machine: config.docker.machine
  #   , (err, saved) ->
  #     saved.should.be.false()
  #     mecano
  #       ssh: ssh
  #     .remove
  #       destination:"#{source}/mecano_saved.tar"
  #     .then next
