
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.user.exists', ->

  they 'user doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_exists'
    .ipa.user.exists
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_exists'
    , (err, {status, exists}) ->
      status.should.be.false() unless err
      exists.should.be.false() unless err
    .promise()

  they 'user exists', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_exists'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [
          'user@nikita.js.org'
        ]
    .ipa.user.exists
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      uid: 'user_exists'
    , (err, {status, exists}) ->
      status.should.be.true() unless err
      exists.should.be.true() unless err
    .promise()
