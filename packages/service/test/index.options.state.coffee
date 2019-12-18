
nikita = require '@nikitajs/core'
{tags, ssh, service} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.service_systemctl

describe 'service options state', ->
  
  @timeout 30000

  they 'should start', ({ssh}) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
      srv_name: service.srv_name
      state: 'started'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.status
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service # Detect already started
      srv_name: service.srv_name
      state: 'started'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should stop', ({ssh}) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
      srv_name: service.srv_name
      state: 'stopped'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.status
      name: service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .service # Detect already stopped
      srv_name: service.srv_name
      state: 'stopped'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should restart', ({ssh}) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
      srv_name: service.srv_name
      state: 'started'
    .service
      srv_name: service.srv_name
      state: 'restarted'
    , (err, {status}) ->
      status.should.be.true()
    .service.stop
      name: service.srv_name
    .service
      srv_name: service.srv_name
      state: 'restarted'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
