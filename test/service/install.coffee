
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service install', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service

  they 'new package', (ssh, next) ->
    mecano
      ssh: ssh
    .service_remove
      name: 'cronie'
    .service
      name: 'cronie'
    , (err, status) ->
      status.should.be.true() unless err
    .execute
      cmd: 'yum list installed | grep cronie'
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'cache', (ssh, next) ->
    mecano
      ssh: ssh
    .service_remove
      name: 'cronie'
    .call (options) ->
      (options.store['mecano:execute:installed'] is undefined).should.be.true()
    .service
      name: 'cronie'
      cache: true
    , (err, status) ->
      status.should.be.true() unless err
    .call (options) ->
      options.store['mecano:execute:installed'].should.containEql 'cronie'
    .execute
      cmd: 'yum list installed | grep cronie'
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'already installed packages', (ssh, next) ->
    mecano
      ssh: ssh
    .service_remove
      name: 'cronie'
    .service
      name: 'cronie'
    .service
      name: 'cronie'
    , (err, status) ->
      status.should.be.false() unless err
    .then next
