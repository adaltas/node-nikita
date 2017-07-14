#Be aware to specify the machine if docker mahcine is used

should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker.pull', ->

  scratch = test.scratch @
  destination = "#{scratch}/default.script"
  source = '/usr/share/udhcpc/default.script'
  config = test.config()
  return if config.disable_docker

  they 'No Image', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'alpine'    
    .docker.pull
      tag: 'alpine'
    , (err, downloaded, stdout, stderr) ->
      downloaded.should.be.true()
    .promise()
  
  they 'Status Not Modified', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'alpine'
    .docker.pull
      tag: 'alpine'
    .docker.pull
      tag: 'alpine'
    , (err, downloaded) ->
      downloaded.should.be.false()
    .promise()
