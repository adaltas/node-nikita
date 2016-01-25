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
      machine: config.docker.machine
    .docker_run
      image: 'httpd'
      name: 'mecano_test_stop'
      service: true
    .docker_stop
      container: 'mecano_test_stop'
    , (err, stopped) ->
      stopped.should.be.true()
    .docker_rm
      container: 'mecano_test_stop'
      force: true
    .then next

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
      machine: config.docker.machine
    .docker_run
      image: 'httpd'
      name: 'mecano_test_stop'
      service: true
    .docker_stop
      container: 'mecano_test_stop'
    .docker_stop
      container: 'mecano_test_stop'
    , (err, stopped) ->
      stopped.should.be.false() unless err
    .docker_rm
      container: 'mecano_test_stop'
      force: true
    .then next
