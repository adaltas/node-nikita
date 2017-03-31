
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.group.remove', ->
  
  config = test.config()
  return if config.disable_system_user
  scratch = test.scratch @
  
  they 'handle status', (ssh, next) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.group 'toto'
    .system.group.remove 'toto', (err, status) ->
      status.should.be.true() unless err
    .system.group.remove 'toto', (err, status) ->
      status.should.be.false() unless err
    .then next
