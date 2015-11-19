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
  machine = 'dev'


  they 'running container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_kill'
      machine: machine
    .docker_run
      image: 'httpd'
      port: '499:80'
      machine: machine
      container: 'mecano_test_kill'
    .docker_kill
      container: 'mecano_test_kill'
      machine: machine
    , (err, killed, stdout, stderr) ->
      killed.should.be.true()
    .docker_rm
      container: 'mecano_test_kill'
      machine: machine
    .then next

  they 'status not modified killed previous', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_kill'
      machine: machine
    .docker_run
      image: 'httpd'
      port: '499:80'
      machine: machine
      container: 'mecano_test_kill'
    .docker_kill
      container: 'mecano_test_kill'
      machine: machine
    .docker_kill
      container: 'mecano_test_kill'
      machine: machine
    , (err, killed) ->
      killed.should.be.false()
    .docker_rm
      container: 'mecano_test_kill'
      machine: machine
    .then next

  they 'status not modified not living', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test_kill'
      machine: machine
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      service: false
      container: 'mecano_test_kill'
      machine: machine
    .docker_kill
      container: 'mecano_test_kill'
      machine: machine
    , (err, killed) ->
      killed.should.be.false()
    .docker_rm
      container: 'mecano_test_kill'
      machine: machine
    .then next
