
they = require 'ssh2-they'
test = require '../test'
conditions = require '../../src/misc/conditions'
nikita = require '../../src'

config = test.config()
return if config.disable_conditions_if_os

describe 'if_os', ->

  they 'match name string', (ssh, next) ->
    conditions.if_os.call nikita(ssh: ssh),
      options:
        if_os: name: config.conditions_is_os.name
      next
      () -> false.should.be.true()

  they 'match name array', (ssh, next) ->
    conditions.if_os.call nikita(ssh: ssh),
      options:
        if_os: name: [config.conditions_is_os.name, 'invalid']
      next
      () -> false.should.be.true()

  they 'match name string and version string', (ssh, next) ->
    conditions.if_os.call nikita(ssh: ssh),
      options:
        if_os: name: config.conditions_is_os.name, version: config.conditions_is_os.version
      next
      () -> false.should.be.true()

  they 'match name string and major version', (ssh, next) ->
    conditions.if_os.call nikita(ssh: ssh),
      options:
        if_os: name: config.conditions_is_os.name, version: config.conditions_is_os.version.split('.')[0]
      next
      () -> false.should.be.true()

describe 'unless_os', ->

  they 'match name string', (ssh, next) ->
    conditions.unless_os.call nikita(ssh: ssh),
      options:
        unless_os: name: config.conditions_is_os.name
      () -> false.should.be.true()
      next

  they 'match name array', (ssh, next) ->
    conditions.unless_os.call nikita(ssh: ssh),
      options:
        unless_os: name: [config.conditions_is_os.name, 'invalid']
      () -> false.should.be.true()
      next

  they 'match array', (ssh, next) ->
    conditions.unless_os.call nikita(ssh: ssh),
      options:
        unless_os: [
          { name: [config.conditions_is_os.name, 'invalid'] }
          { name: 'invalid' }
        ]
      () -> false.should.be.true()
      next
