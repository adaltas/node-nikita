#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

machine = 'ryba'

describe 'docker start', ->

  scratch = test.scratch @

  they 'on stopped container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      name: 'mecano_test_start'
      service: true
      machine: machine
    .docker_stop
      container: 'mecano_test_start'
      machine: machine
    .docker_start
      container: 'mecano_test_start'
      machine: machine
    , (err, started) ->
      started.should.be.true()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_start'
        force: true
        machine: machine
      .then next

  they 'on started container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      container: 'mecano_test_start'
      service: true
      machine: machine
    .docker_stop
      container: 'mecano_test_start'
      machine: machine
    .docker_start
      container: 'mecano_test_start'
      machine: machine
    .docker_start
      container: 'mecano_test_start'
      machine: machine
    , (err, started) ->
      started.should.be.false()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test_start'
        force: true
        machine: machine
      .then next
