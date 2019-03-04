
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.user', ->

  they 'create a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_add'
    .ipa.user
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_add'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [
          'user@nikita.js.org'
        ]
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.user
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_add'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [
          'user@nikita.js.org'
        ]
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
