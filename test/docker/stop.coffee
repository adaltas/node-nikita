#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

machine = 'ryba'

describe 'docker stop', ->

  scratch = test.scratch @
  config = test.config()
  return if config.docker.disable


  they 'on running container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      name: 'mecano_test_stop'
      service: true
      machine: config.docker.machine
    .docker_stop
      container: 'mecano_test_stop'
      machine: config.docker.machine
    , (err, stopped) ->
      stopped.should.be.true()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_stop'
        force: true
        machine: config.docker.machine
      .then next

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      name: 'mecano_test_stop'
      service: true
      machine: config.docker.machine
    .docker_stop
      container: 'mecano_test_stop'
      machine: config.docker.machine
    .docker_stop
      container: 'mecano_test_stop'
      machine: config.docker.machine
    , (err, stopped) ->
      stopped.should.be.false()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_stop'
        force: true
        machine: config.docker.machine
      .then next
