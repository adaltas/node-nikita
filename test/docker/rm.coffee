should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
docker = require '../../src/misc/docker'


describe 'docker rm', ->

  scratch = test.scratch @
  source = "#{scratch}"
  config = test.config()

  they 'remove stopped container', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      force: true
      container: 'mecano_rm'
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'mecano_rm'
      rm: false
    .docker_rm
      container: 'mecano_rm'
    , (err, removed, stdout, stderr) ->
      removed.should.be.true() unless err
    .then next

  they 'remove live container (no force)', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_rm'
      force: true
    .docker_service
      image: 'httpd'
      port: '499:80'
      name: 'mecano_rm'
    .docker_rm
      container: 'mecano_rm'
      relax: true
    , (err, removed, stdout, stderr) ->
      err.message.should.eql 'Container must be stopped to be removed without force'
    .docker_stop
      container: 'mecano_rm'
    .docker_rm
      container: 'mecano_rm'
    .then next

  they 'remove live container (with force)', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_rm
      container: 'mecano_rm'
      force: true
    .docker_service
      image: 'httpd'
      port: '499:80'
      name: 'mecano_rm'
    .docker_rm
      container: 'mecano_rm'
      force: true
    , (err, removed, stdout, stderr) ->
      removed.should.be.true()
      next(err)
