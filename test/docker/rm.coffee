should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
docker = require '../../src/misc/docker'

clean = (ssh, machine, callback) ->
  docker.exec " rm -f 'mecano_rm' || true" , {  ssh: ssh, machine: machine }, null
  , (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

describe 'docker rm', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'


  they 'remove stopped container', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_run
        cmd: "/bin/echo 'test'"
        image: 'alpine'
        machine: machine
        container: 'mecano_rm'
      .docker_rm
        container: 'mecano_rm'
        machine: machine
      , (err, removed, stdout, stderr) ->
        removed.should.be.true()
      .then next

  they 'remove running container (no force)', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: '499:80'
        machine: machine
        container: 'mecano_rm'
      .docker_rm
        container: 'mecano_rm'
        machine: machine
      , (err, removed, stdout, stderr) ->
        err.message.should.eql 'Container must be stopped to be removed without force'
        next()

  they 'remove running container (with force)', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: '499:80'
        machine: machine
        container: 'mecano_rm'
      .docker_rm
        container: 'mecano_rm'
        machine: machine
        force: true
      , (err, removed, stdout, stderr) ->
        removed.should.be.true()
        clean ssh, machine, (err) -> next(err)
