
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

ipa =
  principal: 'admin'
  password: 'admin_pw'
  referer: 'https://ipa.nikita/ipa'
  url: 'https://ipa.nikita/ipa/session/json'

describe 'ipa.group', ->

  they 'create a group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del ipa,
      cn: 'group_add'
    .ipa.group ipa,
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.group ipa,
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
