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
    .docker_rm
      container: 'mecano_status'
      machine: config.docker.machine
      force: true
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      machine: config.docker.machine
      name: 'mecano_status'
    .docker_status
      container: 'mecano_status'
      machine: config.docker.machine
    , (err, running, stdout, stderr) ->
      running.should.be.false()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_status'
        machine: config.docker.machine
        force: true
      .then next

  they 'on running container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_status'
      machine: config.docker.machine
      force: true
    .docker_run
      image: 'httpd'
      port: [ '500:80' ]
      machine: config.docker.machine
      name: 'mecano_status'
      service: true
    .docker_status
      container: 'mecano_status'
      machine: config.docker.machine
    , (err, running, stdout, stderr) ->
      running.should.be.true()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_status'
        machine: config.docker.machine
        force: true
      .then next
