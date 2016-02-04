# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker_status (start, stop)
# So docker_status should is used by other docker command
# For this purpos ip, and clean are used

stream = require 'stream'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'


describe 'docker status', ->

  scratch = test.scratch @
  config = test.config()
  return if config.docker.disable

  they 'on stopped  container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_status'
      force: true
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      name: 'mecano_status'
    .docker_status
      container: 'mecano_status'
    , (err, running, stdout, stderr) ->
      running.should.be.false() unless err
    .docker_rm
      container: 'mecano_status'
      force: true
    .then next

  they 'on running container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_status'
      force: true
    .docker_service
      image: 'httpd'
      port: [ '500:80' ]
      name: 'mecano_status'
    .docker_status
      container: 'mecano_status'
    , (err, running, stdout, stderr) ->
      running.should.be.true()
    .docker_rm
      container: 'mecano_status'
      force: true
    .then next
