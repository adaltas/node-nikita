
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
connect = require 'superexec/lib/connect'
test = require './test'

describe 'service', ->
  
  @timeout 20000
  ssh = null
  config = test.config()
  # return if config
  beforeEach (next) ->
    return next() unless config.yum_over_ssh
    connect config.yum_over_ssh, (err, con) ->
      return next err if err
      ssh = con
      mecano.execute
        ssh: ssh
        cmd: 'yum remove -y ntp'
      , (err, executed, stdout, stderr) ->
        next err
  afterEach (next) ->
    ssh?.end()
    next()
  
  describe 'install', ->

    it 'validate installation', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.execute
          ssh: ssh
          cmd: 'yum list installed | grep ntp'
        , (err, executed) ->
          return next err if err
          executed.should.eql 1
          next()
    
    it 'skip if already installed', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.service
          ssh: ssh
          name: 'ntp'
        , (err, serviced) ->
          return next err if err
          serviced.should.eql 0
          next()

  describe 'startup', ->

    it 'declare on startup with boolean', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.execute
          ssh: ssh
          cmd: 'chkconfig --list ntpd'
          code_skipped: 1
        , (err, startuped) ->
          return next err if err
          startuped.should.eql 1
          next()

    it 'skip if already declared', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: true
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.service
          ssh: ssh
          name: 'ntp'
          srv_name: 'ntpd'
          startup: true
        , (err, serviced) ->
          return next err if err
          serviced.should.eql 0
          next()

    it 'notice a change in startup level', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        startup: '235'
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.service
          ssh: ssh
          name: 'ntp'
          srv_name: 'ntpd'
          startup: '2345'
        , (err, serviced) ->
          return next err if err
          serviced.should.eql 1
          mecano.service
            ssh: ssh
            name: 'ntp'
            srv_name: 'ntpd'
            startup: '2345'
          , (err, serviced) ->
            return next err if err
            serviced.should.eql 0
            next()

    it 'remove after being defined', (next) ->
      return next() unless config.yum_over_ssh
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
          serviced.should.eql 1
          # Validate service not registered
          mecano.execute
            ssh: ssh
            cmd: 'chkconfig --list ntpd'
            code_skipped: 1
          , (err, startuped) ->
            return next err if err
            startuped.should.eql 0
            next()

  describe 'action', ->

    it 'should start', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'start'
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.execute
          ssh: ssh
          cmd: 'service ntpd status'
          code_skipped: 3
        , (err, started) ->
          return next err if err
          started.should.eql 1
          # Detect already started
          mecano.service
            ssh: ssh
            name: 'ntp'
            srv_name: 'ntpd'
            action: 'start'
          , (err, serviced) ->
            return next err if err
            serviced.should.eql 0
            next()

    it 'should stop', (next) ->
      return next() unless config.yum_over_ssh
      mecano.service
        ssh: ssh
        name: 'ntp'
        srv_name: 'ntpd'
        action: 'stop'
      , (err, serviced) ->
        return next err if err
        serviced.should.eql 1
        mecano.execute
          ssh: ssh
          cmd: 'service ntpd status'
          code_skipped: 3
        , (err, started) ->
          return next err if err
          started.should.eql 0
          # Detect already stoped
          mecano.service
            ssh: ssh
            name: 'ntp'
            srv_name: 'ntpd'
            action: 'stop'
          , (err, serviced) ->
            return next err if err
            serviced.should.eql 0
            next()











