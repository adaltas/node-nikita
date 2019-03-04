
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.group', ->

  they 'create a group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'group_add'
    .ipa.group
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.group
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
