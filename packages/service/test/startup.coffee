
nikita = require '@nikitajs/core'
{tags, ssh, service} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.service_startup

describe 'service.startup', ->
  
  @timeout 30000
  
  describe 'startup', ->

    they 'from service', ({ssh}) ->
      nikita
        ssh: ssh
      .service.remove
        name: service.name
      .service
        name: service.name
        chk_name: service.chk_name
        startup: true
      , (err, {status}) ->
        status.should.be.true() unless err
      .service
        name: service.name
        chk_name: service.chk_name
        startup: true
      , (err, {status}) ->
        status.should.be.false() unless err
      .service
        name: service.name
        chk_name: service.chk_name
        startup: false
      , (err, {status}) ->
        status.should.be.true() unless err
      .service
        name: service.name
        chk_name: service.chk_name
        startup: false
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'string argument', ({ssh}) ->
      nikita
        ssh: ssh
      .service.remove
        name: service.name
      .service.install service.name
      .service.startup
        startup: false
        name: service.chk_name
      .service.startup service.chk_name, (err, {status}) ->
        status.should.be.true() unless err
      .promise()
