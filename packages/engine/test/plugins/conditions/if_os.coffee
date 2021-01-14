
nikita = require '../../../src'
{tags, ssh, conditions_if_os} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.conditions_if_os

describe 'plugin.condition if_os', ->
  
  they 'match name string', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {status} = await @call
        if_os: name: conditions_if_os.name
        handler: -> true
      status.should.be.true()
      {status} = await @call
        if_os: name: 'invalid'
        handler: -> true
        ssh: ssh
      status.should.be.false()

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

  they 'match Linux version string', ({ssh}) ->
    {status} = await nikita
      if_os:
        linux_version: conditions_if_os.linux_version
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match name string and major version', ({ssh}) ->
    # Arch Linux has only linux_version
    if conditions_if_os.version
    then condition = version: conditions_if_os.version
    else condition = linux_version: conditions_if_os.linux_version
    {status} = await nikita
      if_os: condition,
        name: conditions_if_os.name
      handler: -> true
      ssh: ssh
    status.should.be.true()
  
  they 'match major Linux version', ({ssh}) ->
    {status} = await nikita
      if_os:
        linux_version: conditions_if_os.linux_version.split('.')[0]
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

  they 'match name string, version string, Linux version string and arch string', ({ssh}) ->
    {status} = await nikita
      if_os: conditions_if_os
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'match array', ({ssh}) ->
    # Arch Linux has only linux_version
    if conditions_if_os.version
    then condition = [version: conditions_if_os.version]
    else condition = [linux_version: conditions_if_os.linux_version]
    condition.push 8
    {status} = await nikita
      if_os: [
        name: conditions_if_os.name
      ,
        condition
      ]
      handler: -> true
      ssh: ssh
    status.should.be.true()
