#Be aware to specify the machine if docker mahcine is used

nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'


describe 'docker.kill', ->

  scratch = test.scratch @
  target = "#{scratch}/default.script"
  source = '/usr/share/udhcpc/default.script'
  config = test.config()
  return if config.disable_docker

  they 'running container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_kill'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'nikita_test_kill'
    .docker.kill
      container: 'nikita_test_kill'
    , (err, killed, stdout, stderr) ->
      killed.should.be.true()
    .promise()

  they 'status not modified (previously killed)', (ssh) ->
    @timeout 120000
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_kill'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'nikita_test_kill'
    .docker.kill
      container: 'nikita_test_kill'
    .docker.kill
      container: 'nikita_test_kill'
    , (err, killed) ->
      killed.should.be.false()
    .promise()

  they 'status not modified (not living)', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_kill'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      name: 'nikita_test_kill'
    .docker.kill
      container: 'nikita_test_kill'
    , (err, killed) ->
      killed.should.be.false()
    .docker.rm
      container: 'nikita_test_kill'
    .promise()
