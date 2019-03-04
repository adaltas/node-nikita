
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

ipa =
  principal: 'admin'
  password: 'admin_pw'
  referer: 'https://ipa.nikita/ipa'
  url: 'https://ipa.nikita/ipa/session/json'

describe 'ipa.user', ->

  they 'create a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del ipa,
      uid: 'user_add'
    .ipa.user ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.user ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'modify a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del ipa,
      uid: 'user_add'
    .ipa.user ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname 1'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    .ipa.user ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname 2'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.user.show ipa,
      uid: 'user_add'
    , (err, {result}) ->
      result.givenname.should.eql ['Firstname 2']
    .promise()
