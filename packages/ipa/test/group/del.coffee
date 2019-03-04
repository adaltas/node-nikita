
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.group.del', ->

  they 'delete a group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'group_del'
    .ipa.group.del
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'group_del'
    , (err, {status}) ->
      status.should.be.true()
    .ipa.group.del
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'group_del'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
