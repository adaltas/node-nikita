should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
docker = require '../../src/misc/docker'


describe 'docker rm', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_docker

  they 'remove stopped container', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'mecano_rm'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'mecano_rm'
      rm: false
    .docker.rm
      container: 'mecano_rm'
    , (err, removed, stdout, stderr) ->
      removed.should.be.true() unless err
    .then next

  they 'remove live container (no force)', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_rm'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'mecano_rm'
    .docker.rm
      container: 'mecano_rm'
      relax: true
    , (err, removed, stdout, stderr) ->
      err.message.should.eql 'Container must be stopped to be removed without force'
    .docker.stop
      container: 'mecano_rm'
    .docker.rm
      container: 'mecano_rm'
    .then next

  they 'remove live container (with force)', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_rm'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'mecano_rm'
    .docker.rm
      container: 'mecano_rm'
      force: true
    , (err, removed, stdout, stderr) ->
      removed.should.be.true()
      next(err)
