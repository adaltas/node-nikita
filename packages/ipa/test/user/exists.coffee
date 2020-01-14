
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.user.exists', ->

  they 'user doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del connection: ipa,
      uid: 'user_exists'
    .ipa.user.exists connection: ipa,
      uid: 'user_exists'
    , (err, {status, exists}) ->
      status.should.be.false() unless err
      exists.should.be.false() unless err
    .promise()

  they 'user exists', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user connection: ipa,
      uid: 'user_exists'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [
          'user@nikita.js.org'
        ]
    .ipa.user.exists connection: ipa,
      uid: 'user_exists'
    , (err, {status, exists}) ->
      status.should.be.true() unless err
      exists.should.be.true() unless err
    .promise()
