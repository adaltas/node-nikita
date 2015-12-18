should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
docker = require '../../src/misc/docker'

describe 'docker rmi', ->

  scratch = test.scratch @
  source = "#{scratch}"
  config = test.config()

  they 'remove image', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      tag: 'mecano/rmi_test:latest'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      machine: config.docker.machine
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: config.docker.machine
    , (err, removed, stdout, stderr) ->
      return err if err
      removed.should.be.true()
    .then next

  they 'status unmodifed', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      tag: 'mecano/rmi_test:latest'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      machine: config.docker.machine
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: config.docker.machine
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: config.docker.machine
    , (err, removed) ->
      removed.should.be.false()
    .then next
