
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.service_systemctl

describe 'service.start', ->
  
  @timeout 20000
  
  they 'should start', ({ssh}) ->
    nikita
      ssh: ssh
    .service
      name: service.name
    .service.stop
      name: service.srv_name
    .service.start
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.status
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.start # Detect already started
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  they 'no error when invalid service name', ({ssh}) ->
    nikita
      ssh: ssh
    .service.start
      name: 'thisdoenstexit'
    , (err, {status}) ->
      (!!err).should.be.false()
      status.should.be.false()
    .promise()
