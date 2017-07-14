
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.group', ->
  
  config = test.config()
  return if config.disable_system_user
  scratch = test.scratch @
  
  they 'accept only user name', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.group 'toto', (err, status) ->
      status.should.be.true() unless err
    .system.group 'toto', (err, status) ->
      status.should.be.false() unless err
    .promise()
    
  they 'accept gid as int or string', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.group 'toto', gid: '1234', (err, status) ->
      status.should.be.true() unless err
    .system.group 'toto', gid: '1234', (err, status) ->
      status.should.be.false() unless err
    .system.group 'toto', gid: 1234, (err, status) ->
      status.should.be.false() unless err
    .promise()
    
  they 'throw if empty gid string', (ssh) ->
    nikita
      ssh: ssh
    .system.group.remove 'toto'
    .system.group 'toto', gid: '', relax: true, (err, status) ->
      err.message.should.eql 'Invalid gid option'
    .promise()
