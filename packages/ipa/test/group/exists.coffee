
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

ipa =
  principal: 'admin'
  password: 'admin_pw'
  referer: 'https://ipa.nikita/ipa'
  url: 'https://ipa.nikita/ipa/session/json'

describe 'ipa.group.exists', ->

  they 'group doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del ipa,
      cn: 'group_exists'
    .ipa.group.exists ipa,
      cn: 'group_exists'
    , (err, {status, exists}) ->
      status.should.be.false() unless err
      exists.should.be.false() unless err
    .promise()

  they 'group exists', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group ipa,
      cn: 'group_exists'
    .ipa.group.exists ipa,
      cn: 'group_exists'
    , (err, {status, exists}) ->
      status.should.be.true() unless err
      exists.should.be.true() unless err
    .promise()
