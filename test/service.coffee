
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
connect = require 'superexec/lib/connect'
test = require './test'

describe 'service', ->

  ssh = null
  config = test.config()
  # return if config
  beforeEach (next) ->
    connect config.yum_over_ssh, (err, con) ->
      return next err if err
      ssh = con
      mecano.execute
        ssh: ssh
        cmd: 'yum remove -y ntp'
      , (err, executed, stdout, stderr) ->
        next err
  
  it 'install', (next) ->
      return next()
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
  
  it 'skip installation', (next) ->
      return next()
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
