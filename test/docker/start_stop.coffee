
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker start', ->

  scratch = test.scratch @

  they 'test stop then start', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      container: 'mecano_test'
      service: true
    .docker_stop
      container: 'mecano_test'
    .execute
      cmd: 'docker ps | grep "mecano_test"'
      code: 1
    .docker_start
      container: 'mecano_test'
    .execute
      cmd: 'docker ps | grep "mecano_test"'
    .docker_rm
      container: 'mecano_test'
      force: true
    .execute
      cmd: 'docker ps -a | grep "mecano_test"'
      code: 1
    .then next
