#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

machine = 'ryba'

describe 'docker start', ->

  scratch = test.scratch @

  they 'test stop then start', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      container: 'mecano_test'
      service: true
      machine: machine
    .docker_stop
      container: 'mecano_test'
      machine: machine
    .docker_status
      container: 'mecano_test'
      machine: machine
      code: 1
    .docker_start
      container: 'mecano_test'
      machine: machine
    .docker_status
      container: 'mecano_test'
      machine: machine
    .docker_rm
      container: 'mecano_test'
      force: true
      machine: machine
    .docker_status
      container: 'mecano_test'
      machine: machine
      exist: true
      code: 1
    .then next
