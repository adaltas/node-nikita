#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

machine = 'ryba'

describe 'docker stop', ->

  scratch = test.scratch @

  they 'on running container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      name: 'mecano_test_stop'
      service: true
      machine: machine
    .docker_stop
      container: 'mecano_test_stop'
      machine: machine
    , (err, stopped) ->
      stopped.should.be.true()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_stop'
        force: true
        machine: machine
      .then next

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      name: 'mecano_test_stop'
      service: true
      machine: machine
    .docker_stop
      container: 'mecano_test_stop'
      machine: machine
    .docker_stop
      container: 'mecano_test_stop'
      machine: machine
    , (err, stopped) ->
      stopped.should.be.false()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_stop'
        force: true
        machine: machine
      .then next
