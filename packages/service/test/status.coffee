
nikita = require '@nikitajs/core'
{tags, ssh, service} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.service_systemctl

describe 'service.status', ->
  
  @timeout 20000
  
  they 'store status', ({ssh}) ->
    nikita
      ssh: ssh
    .service
      name: service.name
    .service.stop
      name: service.srv_name
    .service.status
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .service.start
      name: service.srv_name
    .service.status
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.stop
      name: service.srv_name
    .service.status
      name: service.name
      srv_name: service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
