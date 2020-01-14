
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.group.exists', ->

  they 'group doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del connection: ipa,
      cn: 'group_exists'
    .ipa.group.exists connection: ipa,
      cn: 'group_exists'
    , (err, {status, exists}) ->
      status.should.be.false() unless err
      exists.should.be.false() unless err
    .promise()

  they 'group exists', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group connection: ipa,
      cn: 'group_exists'
    .ipa.group.exists connection: ipa,
      cn: 'group_exists'
    , (err, {status, exists}) ->
      status.should.be.true() unless err
      exists.should.be.true() unless err
    .promise()
