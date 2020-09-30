
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.service.add', ->
  
  they 'delete a missing user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.del connection: ipa,
      uid: 'test_user_del'
    .ipa.service.add connection: ipa,
      uid: 'test_user_del'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
