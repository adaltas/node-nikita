
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
    
  they.only 'parent home does not exist', (ssh, next) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.remove "#{scratch}/toto/subdir"
    .system.user 'toto', home: "#{scratch}/toto/subdir", (err, status) ->
      status.should.be.true() unless err
    .file.assert "#{scratch}/toto",
      mode: 0o0644
      uid: 0
      gid: 0
    .then next
