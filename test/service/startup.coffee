
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
  
  describe 'chkconfig', ->
    
    return if config.disable_service_startup
    return if config.disable_service_systemctl

    they 'notice a change in startup level ', (ssh) ->
      nikita
        ssh: ssh
        # debug: true
      .system.execute 'which chkconfig', code_skipped: 1, (err, {status}) ->
        @end() unless status
      .service
        name: config.service.name
        chk_name: config.service.chk_name
        startup: '235'
      , (err, {status}) ->
        status.should.be.true() unless err
      .service
        chk_name: config.service.chk_name
        startup: '2345'
      , (err, {status}) ->
        status.should.be.true() unless err
      .service
        chk_name: config.service.chk_name
        startup: '2345'
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

  # if config.isCentos7
  #   they 'declare on startup with boolean Centos 7', (ssh) ->
  #     nikita
  #       ssh: ssh
  #     .service.remove
  #       name: config.service.name
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: true
  #     , (err, {status}) ->
  #       status.should.be.true() unless err
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: true
  #     , (err, {status}) ->
  #       status.should.be.false() unless err
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: false
  #     , (err, {status}) ->
  #       status.should.be.true() unless err
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: false
  #     , (err, {status}) ->
  #       status.should.be.false() unless err
  #     .promise()
  #     
  #   they 'declare on startup with boolean CentOS 7', (ssh) ->
  #     nikita
  #       ssh: ssh
  #     .service.remove
  #       name: config.service.name
  #     .service.install config.service.name
  #     .service.startup
  #       startup: false
  #       name: config.service.chk_name
  #     .service.startup config.service.chk_name, (err, {status}) ->
  #       status.should.be.true() unless err
  #     .promise()
