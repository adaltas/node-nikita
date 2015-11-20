should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
docker = require '../../src/misc/docker'

clean = (ssh, machine, callback) ->
  docker.exec " rmi -f mecano/rmi_test:latest || true" , {  ssh: ssh, machine: machine }, null
  , (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

describe 'docker rmi', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'


  they 'remove image', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_build
        image: 'mecano/rmi_test:latest'
        content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
        machine: machine
      .docker_rmi
        image: 'mecano/rmi_test:latest'
        machine: machine
      , (err, removed, stdout, stderr) ->
        removed.should.be.true()
      .then next

  they 'status unmodifed', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: machine
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: machine
    , (err, removed) ->
      removed.should.be.false()
    .then next
