
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.group.del', ->

  they 'delete a group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group connection: ipa,
      cn: 'group_del'
    .ipa.group.del connection: ipa,
      cn: 'group_del'
    , (err, {status}) ->
      status.should.be.true()
    .ipa.group.del connection: ipa,
      cn: 'group_del'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
