should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.save', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_docker

  they 'saves a simple image', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.build
      image: 'nikita/load_test'
      content: "FROM alpine\nCMD ['echo \"hello build from text\"']"
    .docker.save
      image: 'nikita/load_test:latest'
      output: "#{scratch}/nikita_saved.tar"
    , (err, status) ->
      status.should.be.true() unless err
    .promise()

  they.skip 'status not modified', (ssh) ->
    # For now, there are no mechanism to compare the checksum between an old and a new target
    nikita
      ssh: ssh
      docker: config.docker
    .docker.build
      image: 'nikita/load_test'
      content: "FROM alpine\nCMD ['echo \"hello build from text\"']"
    .docker.save
      debug: true
      image: 'nikita/load_test:latest'
      output: "#{scratch}/nikita_saved.tar"
    .docker.save
      image: 'nikita/load_test:latest'
      output: "#{scratch}/nikita_saved.tar"
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
