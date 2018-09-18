
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.system_user

describe 'system.user.remove', ->
  
  they 'handle status', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto'
    .system.user.remove 'toto', (err, {status}) ->
      status.should.be.true() unless err
    .system.user.remove 'toto', (err, {status}) ->
      status.should.be.false() unless err
    .promise()
