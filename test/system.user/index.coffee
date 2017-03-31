
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.user', ->
  
  config = test.config()
  return if config.disable_system_user
  scratch = test.scratch @
  
  they 'accept only user name', (ssh, next) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto', (err, status) ->
      status.should.be.true() unless err
    .system.user 'toto', (err, status) ->
      status.should.be.false() unless err
    .then next
    
  they 'created with a uid', (ssh, next) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto', uid: 1234, (err, status) ->
      status.should.be.true() unless err
    .system.user 'toto', uid: 1235, (err, status) ->
      status.should.be.true() unless err
    .system.user 'toto', uid: 1235, (err, status) ->
      status.should.be.false() unless err
    .system.user 'toto', (err, status) ->
      status.should.be.false() unless err
    .then next
    
  they 'created without a uid', (ssh, next) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto', (err, status) ->
      status.should.be.true() unless err
    .system.user 'toto', uid: 1235, (err, status) ->
      status.should.be.true() unless err
    .system.user 'toto', (err, status) ->
      status.should.be.false() unless err
    .then next
