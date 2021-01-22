
nikita = require '@nikitajs/engine/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.system_group

describe 'system.group', ->
  
  they 'accept only user name', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @system.user.remove 'toto'
      @system.group.remove 'toto'
      {status} = await @system.group 'toto'
      status.should.be.true()
      {status} = await @system.group 'toto'
      status.should.be.false()

  they 'accept gid as int or string', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @system.user.remove 'toto'
      @system.group.remove 'toto'
      {status} = await @system.group 'toto', gid: '1234'
      status.should.be.true()
      {status} = await @system.group 'toto', gid: '1234'
      status.should.be.false()
      {status} = await @system.group 'toto', gid: 1234
      status.should.be.false()

  they 'throw if empty gid string', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @system.group.remove 'toto'
      @system.group 'toto', gid: ''
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
  they 'clean the cache', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @system.group.remove 'toto'
      @call ->
        (@store['nikita:etc_group'] is undefined).should.be.true()
      @system.group.read cache: true, (err) ->
        @store['nikita:etc_group'].should.be.an.Object() unless err
      @system.group 'toto', cache: true, (err) ->
        (@store['nikita:etc_group'] is undefined).should.be.true() unless err
    
