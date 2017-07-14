
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.user.remove', ->
  
  config = test.config()
  return if config.disable_system_user
  scratch = test.scratch @
  
  they 'handle status', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto'
    .system.user.remove 'toto', (err, status) ->
      status.should.be.true() unless err
    .system.user.remove 'toto', (err, status) ->
      status.should.be.false() unless err
    .promise()
