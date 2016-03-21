
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service', ->
  
  @timeout 20000
  config = test.config()
  
  describe 'install', ->

    they 'validate installation', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
      , (err, installed) ->
        installed.should.be.true()
      .execute
        cmd: 'yum list installed | grep ntp'
      , (err, executed) ->
        executed.should.be.true()
      .then next
    
    they 'skip if already installed', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
      , (err, installed) ->
        installed.should.be.true()
      .service
        name: 'ntp'
      , (err, installed) ->
        installed.should.be.false()
      .then next

  describe 'startup', ->

    they 'declare on startup with boolean', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        serviced.should.be.true()
      .execute
        cmd: 'chkconfig --list ntpd'
        code_skipped: 1
      , (err, startuped) ->
        startuped.should.be.true()
      .then next

    they 'skip if already declared', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        serviced.should.be.true()
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        serviced.should.be.false()
      .then next

    they 'notice a change in startup level', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '235'
      , (err, serviced) ->
        serviced.should.be.true()
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '2345'
      , (err, serviced) ->
        serviced.should.be.true()
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '2345'
      , (err, serviced) ->
        serviced.should.be.false()
      .then next

    they 'remove after being defined', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service # Register service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        return next err if err
      .service # Unregister service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: false
      , (err, serviced) ->
        return next err if err
        serviced.should.be.true()
      .execute # Validate service not registered
        cmd: 'chkconfig --list ntpd'
        code_skipped: 1
      , (err, startuped) ->
        return next err if err
        startuped.should.be.false()
      .then next

  describe 'action', ->

    they 'should start', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'start'
      , (err, serviced) ->
        serviced.should.be.true()
      .service_status
        name: 'ntpd'
      , (err, started) ->
        started.should.be.true()
      .service # Detect already started
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'start'
      , (err, serviced) ->
        serviced.should.be.false()
      .then next

    they 'should stop', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'stop'
      , (err, serviced) ->
        serviced.should.be.true()
      .service_status
        name: 'ntpd'
      , (err, started) ->
        started.should.be.false()
      .service # Detect already stopped
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'stop'
      , (err, serviced) ->
        serviced.should.be.false()
      .then next

    they 'should restart', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'restart'
      , (err, restarted) ->
        restarted.should.be.true()
      .then next

  describe 'service_action', ->

    they 'should start', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service_stop
        name: 'ntpd'
      .service_start
        name: 'ntpd'
      , (err, started) ->
        started.should.be.true()
      .service_status
        name: 'ntpd'
      , (err, started) ->
        started.should.be.true()
      .service_start # Detect already started
        name: 'ntpd'
      , (err, started) ->
        started.should.be.false()
      .then next

    they 'should stop', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service_stop
        name: 'ntpd'
      , (err, stopped) ->
        stopped.should.be.true()
      .service_status
        name: 'ntpd'
      , (err, started) ->
        started.should.be.false()
      .service_stop # Detect already stopped
        name: 'ntpd'
      , (err, stopped) ->
        stopped.should.be.false()
      .then next

    they 'should restart', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service_restart
        name: 'ntpd'
      , (err, restarted) ->
        restarted.should.be.true()
      .then next










