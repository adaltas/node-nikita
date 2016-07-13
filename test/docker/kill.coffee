#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker kill', ->

  scratch = test.scratch @
  target = "#{scratch}/default.script"
  source = '/usr/share/udhcpc/default.script'
  config = test.config()
  return if config.disable_docker


  they 'running container', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_test_kill'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'mecano_test_kill'
    .docker.kill
      container: 'mecano_test_kill'
    , (err, killed, stdout, stderr) ->
      killed.should.be.true()
    .then next

  they 'status not modified (previously killed)', (ssh, next) ->
    @timeout 120000
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_test_kill'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'mecano_test_kill'
    .docker.kill
      container: 'mecano_test_kill'
    .docker.kill
      container: 'mecano_test_kill'
    , (err, killed) ->
      killed.should.be.false()
    .then next

  they 'status not modified (not living)', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_test_kill'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      name: 'mecano_test_kill'
    .docker.kill
      container: 'mecano_test_kill'
    , (err, killed) ->
      killed.should.be.false()
    .docker.rm
      container: 'mecano_test_kill'
    .then next
