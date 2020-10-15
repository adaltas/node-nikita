
nikita = require '@nikitajs/engine/src'
{tags, ssh, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.group.del', ->

  they 'delete a group', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @ipa.group connection: ipa,
        cn: 'group_del'
      {status} = await @ipa.group.del connection: ipa,
        cn: 'group_del'
      status.should.be.true()
      {status} = await @ipa.group.del connection: ipa,
        cn: 'group_del'
      status.should.be.false()
