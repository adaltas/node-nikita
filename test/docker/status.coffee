# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker.status (start, stop)
# So docker.status should is used by other docker command
# For this purpos ip, and clean are used

stream = require 'stream'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'


describe 'docker.status', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_docker

  they 'on stopped  container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_status'
      force: true
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      name: 'nikita_status'
    .docker.status
      container: 'nikita_status'
    , (err, running, stdout, stderr) ->
      running.should.be.false() unless err
    .docker.rm
      container: 'nikita_status'
      force: true
    .promise()

  they 'on running container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_status'
      force: true
    .docker.service
      image: 'httpd'
      port: [ '500:80' ]
      name: 'nikita_status'
    .docker.status
      container: 'nikita_status'
    , (err, running, stdout, stderr) ->
      running.should.be.true()
    .docker.rm
      container: 'nikita_status'
      force: true
    .promise()
