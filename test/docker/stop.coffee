#Be aware to specify the machine if docker mahcine is used

nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

machine = 'ryba'

describe 'docker.stop', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_docker

  they 'on running container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.service
      image: 'httpd'
      name: 'nikita_test_stop'
    .docker.stop
      container: 'nikita_test_stop'
    , (err, stopped) ->
      stopped.should.be.true()
    .docker.rm
      container: 'nikita_test_stop'
      force: true
    .promise()

  they 'on stopped container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.service
      image: 'httpd'
      name: 'nikita_test_stop'
    .docker.stop
      container: 'nikita_test_stop'
    .docker.stop
      container: 'nikita_test_stop'
    , (err, stopped) ->
      stopped.should.be.false() unless err
    .docker.rm
      container: 'nikita_test_stop'
      force: true
    .promise()
