
fs = require 'ssh2-fs'
mecano = require '../../src'
path = require 'path'
should = require 'should'
test = require '../test'
they = require 'ssh2-they'


describe 'docker cp', ->

  config = test.config()
  scratch = test.scratch @
  @timeout 20000
  
  they 'a remote file to a local file', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_extract'
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      cmd: "whoami"
      rm: false
    .docker_cp
      source: 'mecano_extract:/etc/apk/repositories'
      destination: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .call ->
      fs.exists ssh, "#{scratch}/a_file", (err, exists) ->
        exists.should.be.true() unless err
    .docker_rm
      container: 'mecano_extract'
    .then next
    
  they 'a remote file to a local directory', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm container: 'mecano_extract'
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      cmd: "whoami"
      rm: false
    .docker_cp
      source: 'mecano_extract:/etc/apk/repositories'
      destination: "#{scratch}"
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/repositories", (err, exists) ->
        exists.should.be.true() unless err
        callback()
    .docker_rm container: 'mecano_extract'
    .then next
    
  they 'a local file to a remote file', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm container: 'mecano_extract'
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      volume: "#{scratch}:/root"
      cmd: "whoami"
      rm: false
    .docker_cp
      source: "#{__filename}"
      destination: "mecano_extract:/root/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .docker_cp
      source: 'mecano_extract:/root/a_file'
      destination: "#{scratch}"
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/a_file", (err, exists) ->
        exists.should.be.true() unless err
        callback()
    .docker_rm container: 'mecano_extract'
    .then next
    
  they 'a local file to a remote directory', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm container: 'mecano_extract'
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      volume: "#{scratch}:/root"
      cmd: "whoami"
      rm: false
    .docker_cp
      source: "#{__filename}"
      destination: "mecano_extract:/root"
    , (err, status) ->
      status.should.be.true() unless err
    .docker_cp
      source: "mecano_extract:/root/#{path.basename __filename}"
      destination: "#{scratch}"
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/#{path.basename __filename}", (err, exists) ->
        exists.should.be.true() unless err
        callback()
    .docker_rm container: 'mecano_extract'
    .then next
