
nikita = require '../../../src'
{tags, ssh, conditions_if_os} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.conditions_if_os

describe 'plugin.condition if_os', ->
  
  they 'match name string', ({ssh}) ->
    {status} = await nikita
      if_os: name: conditions_if_os.name
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match name array', ({ssh}) ->
    {status} = await nikita
      if_os: name: [conditions_if_os.name, 'invalid']
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match name string and version string', ({ssh}) ->
    {status} = await nikita
      if_os:
        name: conditions_if_os.name
        version: conditions_if_os.version
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match name string and major version', ({ssh}) ->
    {status} = await nikita
      if_os:
        name: conditions_if_os.name
        version: conditions_if_os.version.split('.')[0]
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match arch string', ({ssh}) ->
    {status} = await nikita
      if_os:
        arch: conditions_if_os.arch
      handler: -> true
      ssh: ssh
    status.should.be.true()
  
  they 'match array', ({ssh}) ->
    {status} = await nikita
      if_os: [
        name: conditions_if_os.name
      ,
        version: [conditions_if_os.version, '8']
      ]
      handler: -> true
      ssh: ssh
    status.should.be.true()
