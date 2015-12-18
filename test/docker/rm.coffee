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
    .docker_rm
      force: true
      container: 'mecano_rm'
      machine: config.docker.machine
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      machine: config.docker.machine
      name: 'mecano_rm'
      service: false
      rm: false
    .docker_rm
      container: 'mecano_rm'
      machine: config.docker.machine
    , (err, removed, stdout, stderr) ->
      return err if err
      removed.should.be.true()
    .then next

  they 'remove live container (no force)', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_rm'
      machine: config.docker.machine
      force: true
    .docker_run
      image: 'httpd'
      port: '499:80'
      name: 'mecano_rm'
      machine: config.docker.machine
      service: true
      rm: false
    .docker_rm
      container: 'mecano_rm'
      machine: config.docker.machine
    , (err, removed, stdout, stderr) ->
      err.message.should.eql 'Container must be stopped to be removed without force'
      next()

  they 'remove live container (with force)', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_rm'
      machine: config.docker.machine
      force: true
    .docker_run
      image: 'httpd'
      port: '499:80'
      machine: config.docker.machine
      name: 'mecano_rm'
      service: true
      rm: false
    .docker_rm
      container: 'mecano_rm'
      machine: config.docker.machine
      force: true
    , (err, removed, stdout, stderr) ->
      removed.should.be.true()
      next(err)
