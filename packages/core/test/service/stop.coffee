
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.service_systemctl

describe 'service.stop', ->
  
  @timeout 20000

  they 'should stop', ({ssh}) ->
    nikita
      ssh: ssh
    .service.install service.name
    .service.start service.srv_name
    .service.stop service.srv_name, (err, {status}) ->
      status.should.be.true() unless err
    .service.stop service.srv_name, (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'no error when invalid service name', ({ssh}) ->
    nikita
      ssh: ssh
    .service.stop
      name: 'thisdoenstexit'
      relax: true
    , (err, {status}) ->
      status.should.be.false()
    .promise()
