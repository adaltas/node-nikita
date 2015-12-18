#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker kill', ->

  scratch = test.scratch @
  destination = "#{scratch}/default.script"
  source = '/usr/share/udhcpc/default.script'
  config = test.config()
  return if config.docker.disable


  they 'running container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_kill'
      machine: config.docker.machine
      force: true
    .docker_run
      image: 'httpd'
      port: '499:80'
      machine: config.docker.machine
      name: 'mecano_test_kill'
      service: true
    .docker_kill
      container: 'mecano_test_kill'
      machine: config.docker.machine
    , (err, killed, stdout, stderr) ->
      killed.should.be.true()
      next(err)

  they 'status not modified (previously killed)', (ssh, next) ->
    @timeout 120000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_kill'
      machine: config.docker.machine
      force: true
    .docker_run
      image: 'httpd'
      port: '499:80'
      machine: config.docker.machine
      name: 'mecano_test_kill'
      service: true
    .docker_kill
      container: 'mecano_test_kill'
      machine: config.docker.machine
    .docker_kill
      container: 'mecano_test_kill'
      machine: config.docker.machine
    , (err, killed) ->
      killed.should.be.false()
      next(err)

  they 'status not modified (not living)', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_kill'
      machine: config.docker.machine
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      service: false
      name: 'mecano_test_kill'
      machine: config.docker.machine
    .docker_kill
      container: 'mecano_test_kill'
      machine: config.docker.machine
    , (err, killed) ->
      killed.should.be.false()
    .docker_rm
      container: 'mecano_test_kill'
      machine: config.docker.machine
    .then next
