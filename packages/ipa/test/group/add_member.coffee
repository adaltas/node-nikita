
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

ipa =
  principal: 'admin'
  password: 'admin_pw'
  referer: 'https://ipa.nikita/ipa'
  url: 'https://ipa.nikita/ipa/session/json'

describe 'ipa.group.add_member', ->

  they 'add_member to a group', ({ssh}) ->
    gidnumber = null
    nikita
      ssh: ssh
    .ipa.group.del ipa, [
      cn: 'group_add_member'
    ,
      cn: 'group_add_member_user'
    ]
    .ipa.user.del ipa,
      uid: 'group_add_member_user'
    .ipa.group ipa,
      cn: 'group_add_member'
    , (err, {result}) ->
      gidnumber = result.gidnumber
    .ipa.user ipa,
      uid: 'group_add_member_user'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    .ipa.group.add_member ipa,
      cn: 'group_add_member'
      attributes:
        user: ['group_add_member_user']
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.group.show ipa,
      cn: 'group_add_member'
    , (err, {result}) ->
      result.gidnumber.should.eql gidnumber
    .promise()
