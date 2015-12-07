should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker save', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'


  they 'saves a simple image', (ssh, next) ->
    mecano
      ssh: ssh
    .remove
      destination:"#{source}/mecano_saved.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{source}/mecano_saved.tar"
      machine: machine
    , (err, saved) ->
      saved.should.be.true()
    .remove
      destination:"#{source}/mecano_saved.tar"
    .then next

  they 'status not modified', (ssh, next) ->
    mecano
      ssh: ssh
    .remove
      destination:"#{source}/mecano_saved.tar"
    .docker_build
      tag: 'mecano/load_test:latest'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{source}/mecano_saved.tar"
      machine: machine
    .docker_save
      image: 'mecano/load_test:latest'
      output: "#{source}/mecano_saved.tar"
      machine: machine
    , (err, saved) ->
      saved.should.be.false()
    .remove
      destination:"#{source}/mecano_saved.tar"
    .then next
