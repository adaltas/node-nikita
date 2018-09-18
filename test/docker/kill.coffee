
nikita = require '../../src'
{tags, ssh, scratch, docker} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.docker

describe 'docker.kill', ->

  target = "#{scratch}/default.script"
  source = '/usr/share/udhcpc/default.script'

  they 'running container', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_test_kill'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      name: 'nikita_test_kill'
    .docker.kill
      container: 'nikita_test_kill'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'status not modified (previously killed)', (ssh) ->
    @timeout 120000
    nikita
      ssh: ssh
      docker: docker
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
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'status not modified (not living)', (ssh) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_test_kill'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      rm: false
      name: 'nikita_test_kill'
    .docker.kill
      container: 'nikita_test_kill'
    , (err, {status}) ->
      status.should.be.false()
    .docker.rm
      container: 'nikita_test_kill'
    .promise()
