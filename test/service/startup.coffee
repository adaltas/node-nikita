
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.startup', ->
  
  @timeout 30000
  config = test.config()
  
  describe 'startup', ->

    return if config.disable_service_startup

    they 'from service', (ssh) ->
      nikita
        ssh: ssh
      .service.remove
        name: config.service.name
      .service
        name: config.service.name
        chk_name: config.service.chk_name
        startup: true
      , (err, {status}) ->
        status.should.be.true() unless err
      .service
        name: config.service.name
        chk_name: config.service.chk_name
        startup: true
      , (err, {status}) ->
        status.should.be.false() unless err
      .service
        name: config.service.name
        chk_name: config.service.chk_name
        startup: false
      , (err, {status}) ->
        status.should.be.true() unless err
      .service
        name: config.service.name
        chk_name: config.service.chk_name
        startup: false
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'string argument', (ssh) ->
      nikita
        ssh: ssh
      .service.remove
        name: config.service.name
      .service.install config.service.name
      .service.startup
        startup: false
        name: config.service.chk_name
      .service.startup config.service.chk_name, (err, {status}) ->
        status.should.be.true() unless err
      .promise()
