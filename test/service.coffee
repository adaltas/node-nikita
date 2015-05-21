
mecano = require "../src"
test = require './test'
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
      , (err, serviced) ->
        serviced.should.be.ok
      .execute
        cmd: 'yum list installed | grep ntp'
      , (err, executed) ->
        executed.should.be.ok
      .then next
    
    they 'skip if already installed', (ssh, next) ->
      return next() unless config.test_service
      mecano
        ssh: ssh
      .service
        name: 'ntp'
      , (err, serviced) ->
        serviced.should.be.ok
      .service
        name: 'ntp'
      , (err, serviced) ->
        serviced.should.not.be.ok
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
        serviced.should.be.ok
      .execute
        cmd: 'chkconfig --list ntpd'
        code_skipped: 1
      , (err, startuped) ->
        startuped.should.be.ok
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
        serviced.should.be.ok
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        serviced.should.not.be.ok
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
        serviced.should.be.ok
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '2345'
      , (err, serviced) ->
        serviced.should.be.ok
      .service
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '2345'
      , (err, serviced) ->
        serviced.should.not.be.ok
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
        serviced.should.be.ok
      .execute # Validate service not registered
        cmd: 'chkconfig --list ntpd'
        code_skipped: 1
      , (err, startuped) ->
        return next err if err
        startuped.should.not.be.ok
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
        serviced.should.be.ok
      .execute
        cmd: 'service ntpd status'
        code_skipped: 3
      , (err, started) ->
        started.should.be.ok
      .service # Detect already started
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'start'
      , (err, serviced) ->
        serviced.should.not.be.ok
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
        serviced.should.be.ok
      .execute
        cmd: 'service ntpd status'
        code_skipped: 3
      , (err, started) ->
        started.should.not.be.ok
      .service # Detect already stopped
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'stop'
      , (err, serviced) ->
        serviced.should.not.be.ok
      .then next











