
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.install', ->
  
  @timeout 50000
  config = test.config()
  return if config.disable_service_install

  they 'new package', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    , (err, status) ->
      status.should.be.true() unless err
    .promise()
  
  they 'already installed packages', (ssh) ->
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
    .promise()

  they 'name as default argument', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service config.service.name, (err, status) ->
      status.should.be.true() unless err
    .promise()
  
  they 'cache', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .call (options) ->
      (@store['nikita:execute:installed'] is undefined).should.be.true()
    .service
      name: config.service.name
      cache: true
    , (err, status) ->
      status.should.be.true() unless err
    .call (options) ->
      @store['nikita:execute:installed'].should.containEql config.service.name
    .promise()

  they 'skip code when error', (ssh) ->
    nikita
      ssh: ssh
    .service.install
      name: 'thisservicedoesnotexist'
      code_skipped: [1, 100] # 1 for RH, 100 for Ubuntu
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
