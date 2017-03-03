
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.install', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service
  process.env['TMPDIR'] = '/var/tmp' if config.isCentos6 or config.isCentos7

  they 'new package', (ssh, next) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    , (err, status) ->
      status.should.be.true() unless err
    .then next
  
  they 'already installed packages', (ssh, next) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service
      name: config.service.name
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'name as default argument', (ssh, next) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service config.service.name, (err, status) ->
      status.should.be.true() unless err
    .then next
  
  they 'cache', (ssh, next) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .call (options) ->
      (options.store['nikita:execute:installed'] is undefined).should.be.true()
    .service
      name: config.service.name
      cache: true
    , (err, status) ->
      status.should.be.true() unless err
    .call (options) ->
      options.store['nikita:execute:installed'].should.containEql config.service.name
    .then next

  they 'skip code when error', (ssh, next) ->
    nikita
      ssh: ssh
    .service.install
      name: 'thisservicedoesnotexist'
      code_skipped: 1
    , (err, status) ->
      (!!err).should.be.false()
      status.should.be.false() unless err
    .then next
