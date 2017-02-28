
fs = require 'ssh2-fs'
mecano = require '../../src'
path = require 'path'
should = require 'should'
test = require '../test'
they = require 'ssh2-they'


describe 'docker.cp', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @
  @timeout 20000
  
  they 'a remote file to a local file', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_extract'
    .docker.run
      name: 'mecano_extract'
      image: 'alpine'
      cmd: "whoami"
      rm: false
    .docker.cp
      source: 'mecano_extract:/etc/apk/repositories'
      target: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/a_file", (err, exists) ->
        exists.should.be.true() unless err
        callback err
    .docker.rm
      container: 'mecano_extract'
    .then next
    
  they 'a remote file to a local directory', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm container: 'mecano_extract'
    .docker.run
      name: 'mecano_extract'
      image: 'alpine'
      cmd: "whoami"
      rm: false
    .docker.cp
      source: 'mecano_extract:/etc/apk/repositories'
      target: "#{scratch}"
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/repositories", (err, exists) ->
        exists.should.be.true() unless err
        callback()
    .docker.rm container: 'mecano_extract'
    .then next
    
  they 'a local file to a remote file', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm container: 'mecano_extract'
    .docker.run
      name: 'mecano_extract'
      image: 'alpine'
      volume: "#{scratch}:/root"
      cmd: "whoami"
      rm: false
    .docker.cp
      source: "#{__filename}"
      target: "mecano_extract:/root/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .docker.cp
      source: 'mecano_extract:/root/a_file'
      target: "#{scratch}"
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/a_file", (err, exists) ->
        exists.should.be.true() unless err
        callback()
    .docker.rm container: 'mecano_extract'
    .then next
    
  they 'a local file to a remote directory', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm container: 'mecano_extract'
    .docker.run
      name: 'mecano_extract'
      image: 'alpine'
      volume: "#{scratch}:/root"
      cmd: "whoami"
      rm: false
    .docker.cp
      source: "#{__filename}"
      target: "mecano_extract:/root"
    , (err, status) ->
      status.should.be.true() unless err
    .docker.cp
      source: "mecano_extract:/root/#{path.basename __filename}"
      target: "#{scratch}"
    .call (_, callback) ->
      fs.exists ssh, "#{scratch}/#{path.basename __filename}", (err, exists) ->
        exists.should.be.true() unless err
        callback()
    .docker.rm container: 'mecano_extract'
    .then next
