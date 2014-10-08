
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
test = require './test'
they = require 'ssh2-they'

describe 'service', ->
  
  @timeout 20000
  config = test.config()
  
  describe 'install', ->

    they 'validate installation', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.execute
          ssh: ssh
          cmd: 'yum list installed | grep ntp'
        , (err, executed) ->
          return next err if err
          executed.should.be.ok
          next()
    
    they 'skip if already installed', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.service
          ssh: ssh
          name: 'ntp'
        , (err, serviced) ->
          return next err if err
          serviced.should.not.be.ok
          next()

  describe 'startup', ->

    they 'declare on startup with boolean', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.execute
          ssh: ssh
          cmd: 'chkconfig --list ntpd'
          code_skipped: 1
        , (err, startuped) ->
          return next err if err
          startuped.should.be.ok
          next()

    they 'skip if already declared', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.service
          ssh: ssh
          name: 'ntp'
          srv_name: 'ntpd'
          startup: true
        , (err, serviced) ->
          return next err if err
          serviced.should.not.be.ok
          next()

    they 'notice a change in startup level', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '235'
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.service
          ssh: ssh
          name: 'ntp'
          srv_name: 'ntpd'
          startup: '2345'
        , (err, serviced) ->
          return next err if err
          serviced.should.be.ok
          mecano.service
            ssh: ssh
            name: 'ntp'
            srv_name: 'ntpd'
            startup: '2345'
          , (err, serviced) ->
            return next err if err
            serviced.should.not.be.ok
            next()

    they 'remove after being defined', (ssh, next) ->
      return next() unless config.test_service
      # Register service
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        return next err if err
        # Unregister service
        mecano.service
          ssh: ssh
          name: 'ntp'
          srv_name: 'ntpd'
          startup: false
        , (err, serviced) ->
          return next err if err
          serviced.should.be.ok
          # Validate service not registered
          mecano.execute
            ssh: ssh
            cmd: 'chkconfig --list ntpd'
            code_skipped: 1
          , (err, startuped) ->
            return next err if err
            startuped.should.not.be.ok
            next()

  describe 'action', ->

    they 'should start', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'start'
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.execute
          ssh: ssh
          cmd: 'service ntpd status'
          code_skipped: 3
        , (err, started) ->
          return next err if err
          started.should.be.ok
          # Detect already started
          mecano.service
            ssh: ssh
            name: 'ntp'
            srv_name: 'ntpd'
            action: 'start'
          , (err, serviced) ->
            return next err if err
            serviced.should.not.be.ok
            next()

    they 'should stop', (ssh, next) ->
      return next() unless config.test_service
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'stop'
      , (err, serviced) ->
        return next err if err
        serviced.should.be.ok
        mecano.execute
          ssh: ssh
          cmd: 'service ntpd status'
          code_skipped: 3
        , (err, started) ->
          return next err if err
          started.should.not.be.ok
          # Detect already stopped
          mecano.service
            ssh: ssh
            name: 'ntp'
            srv_name: 'ntpd'
            action: 'stop'
          , (err, serviced) ->
            return next err if err
            serviced.should.not.be.ok
            next()











