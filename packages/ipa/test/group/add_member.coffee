
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.group.add_member', ->

  they 'add_member to a group', ({ssh}) ->
    gidnumber = null
    nikita
      ssh: ssh
    .ipa.group.del connection: ipa, [
      cn: 'group_add_member'
    ,
      cn: 'group_add_member_user'
    ]
    .ipa.user.del connection: ipa,
      uid: 'group_add_member_user'
    .ipa.group connection: ipa,
      cn: 'group_add_member'
    , (err, {result}) ->
      throw err if err
      gidnumber = result.gidnumber
    .ipa.user connection: ipa,
      uid: 'group_add_member_user'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    .ipa.group.add_member connection: ipa,
      cn: 'group_add_member'
      attributes:
        user: ['group_add_member_user']
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.group.show connection: ipa,
      cn: 'group_add_member'
    , (err, {result}) ->
      result.gidnumber.should.eql gidnumber
    .promise()
