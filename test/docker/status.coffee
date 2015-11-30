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

clean = (ssh, machine, container, callback) ->
  docker.exec " rm -f #{container} || true" , {  ssh: ssh, machine: machine }, null
  , (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

describe 'docker status', ->

  scratch = test.scratch @

  machine = 'dev'

  they 'on stopped  container', (ssh, next) ->
    clean ssh, machine, 'mecano_status', (err) =>
      mecano
        ssh: ssh
      .docker_run
        cmd: "/bin/echo 'test'"
        image: 'alpine'
        rm: false
        machine: machine
        name: 'mecano_status'
      .docker_status
        container: 'mecano_status'
        machine: machine
      , (err, running, stdout, stderr) ->
        running.should.be.false()
        clean ssh, machine, 'mecano_status', (err) -> next()

  they 'on running container', (ssh, next) ->
    clean ssh, machine, 'mecano_status', (err) =>
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: [ '500:80' ]
        machine: machine
        name: 'mecano_status'
      .docker_status
        container: 'mecano_status'
        machine: machine
      , (err, running, stdout, stderr) ->
        running.should.be.true()
        clean ssh, machine, 'mecano_status', (err) -> next()
