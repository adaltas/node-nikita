
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.user.del', ->
  
  they 'delete a missing user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del connection: ipa,
      uid: 'test_user_del'
    .ipa.user.del connection: ipa,
      uid: 'test_user_del'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'delete a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user connection: ipa,
      uid: 'test_user_del'
      attributes:
        givenname: 'User'
        sn: 'Delete'
        mail: [
          'test_user_del@nikita.js.org'
        ]
    .ipa.user.del connection: ipa,
      uid: 'test_user_del'
    , (err, {status}) ->
      status.should.be.true()
    .promise()
