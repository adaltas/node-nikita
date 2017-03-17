
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.startup', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service_startup
  
  they 'from service', (ssh, next) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: true
    , (err, status) ->
      status.should.be.true() unless err
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: true
    , (err, status) ->
      status.should.be.false() unless err
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: false
    , (err, status) ->
      status.should.be.true() unless err
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: false
    , (err, status) ->
      status.should.be.false() unless err
    .then next
    
  they 'string argument', (ssh, next) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service.install config.service.name
    .service.startup
      startup: false
      name: config.service.chk_name
    .service.startup config.service.chk_name, (err, status) ->
      status.should.be.true() unless err
    .then next
  
  describe 'chkconfig', ->

    they 'notice a change in startup level ', (ssh, next) ->
      nikita
        ssh: ssh
      .system.execute 'which chkconfig', code_skipped: 1, (err, status) ->
        @end() unless status
      .service
        name: config.service.name
        chk_name: config.service.chk_name
        startup: '235'
      , (err, status) ->
        status.should.be.true() unless err
      .service
        chk_name: config.service.chk_name
        startup: '2345'
      , (err, status) ->
        status.should.be.true() unless err
      .service
        chk_name: config.service.chk_name
        startup: '2345'
      , (err, status) ->
        status.should.be.false() unless err
      .then next

  # if config.isCentos7
  #   they 'declare on startup with boolean Centos 7', (ssh, next) ->
  #     nikita
  #       ssh: ssh
  #     .service.remove
  #       name: config.service.name
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: true
  #     , (err, status) ->
  #       status.should.be.true() unless err
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: true
  #     , (err, status) ->
  #       status.should.be.false() unless err
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: false
  #     , (err, status) ->
  #       status.should.be.true() unless err
  #     .service
  #       name: config.service.name
  #       chk_name: config.service.chk_name
  #       startup: false
  #     , (err, status) ->
  #       status.should.be.false() unless err
  #     .then next
  #     
  #   they 'declare on startup with boolean CentOS 7', (ssh, next) ->
  #     nikita
  #       ssh: ssh
  #     .service.remove
  #       name: config.service.name
  #     .service.install config.service.name
  #     .service.startup
  #       startup: false
  #       name: config.service.chk_name
  #     .service.startup config.service.chk_name, (err, status) ->
  #       status.should.be.true() unless err
  #     .then next
