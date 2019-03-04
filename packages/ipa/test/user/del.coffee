
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

ipa =
  principal: 'admin'
  password: 'admin_pw'
  referer: 'https://ipa.nikita/ipa'
  url: 'https://ipa.nikita/ipa/session/json'

describe 'ipa.user.del', ->

  they 'delete a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user ipa,
      uid: 'user_del'
      attributes:
        givenname: 'User'
        sn: 'Delete'
        mail: [
          'user_del@nikita.js.org'
        ]
    .ipa.user.del ipa,
      uid: 'user_del'
    , (err, {status}) ->
      status.should.be.true()
    .ipa.user.del ipa,
      uid: 'user_del'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
