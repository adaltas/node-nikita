
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.system_user

describe 'system.group', ->
  
  they 'accept only user name', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.group 'toto', (err, {status}) ->
      status.should.be.true() unless err
    .system.group 'toto', (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'accept gid as int or string', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.group 'toto', gid: '1234', (err, {status}) ->
      status.should.be.true() unless err
    .system.group 'toto', gid: '1234', (err, {status}) ->
      status.should.be.false() unless err
    .system.group 'toto', gid: 1234, (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'throw if empty gid string', (ssh) ->
    nikita
      ssh: ssh
    .system.group.remove 'toto'
    .system.group 'toto', gid: '', relax: true, (err) ->
      err.message.should.eql 'Invalid gid option'
    .promise()
  
  they 'clean the cache', (ssh) ->
    nikita
      ssh: ssh
    .system.group.remove 'toto'
    .call ->
      (@store['nikita:etc_group'] is undefined).should.be.true()
    .system.group.read cache: true, (err) ->
      @store['nikita:etc_group'].should.be.an.Object() unless err
    .system.group 'toto', cache: true, (err) ->
      (@store['nikita:etc_group'] is undefined).should.be.true() unless err
    .promise()
    
