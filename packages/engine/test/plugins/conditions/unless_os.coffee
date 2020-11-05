
nikita = require '../../../src'
{tags, ssh, conditions_if_os} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.conditions_if_os

describe 'plugin.condition unless_os', ->

  they 'match name string', ({ssh}) ->
    {status} = await nikita
      unless_os: name: 'invalid', version: '1'
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match name array', ({ssh}) ->
    {status} = await nikita
      unless_os: name: ['invalid1', 'invalid2']
      handler: -> true
      ssh: ssh
    status.should.be.true()
    
  they 'match name string and version string', ({ssh}) ->
    {status} = await nikita
      unless_os:
        name: 'invalid'
        version: '1'
      handler: -> true
      ssh: ssh
    status.should.be.true()
    
  they 'match name string, version string anf arch string', ({ssh}) ->
    {status} = await nikita
      unless_os: conditions_if_os
      handler: -> true
      ssh: ssh
    status.should.be.false()

  they 'match array', ({ssh}) ->
    {status} = await nikita
      unless_os: [
        { name: ['invalid1', 'invalid2'] }
        { name: 'invalid' }
      ]
      handler: -> true
      ssh: ssh
    status.should.be.true()
