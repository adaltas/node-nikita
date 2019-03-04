
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.group.show', ->

  they 'get single group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.show
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'admins'
    , (err, {result}) ->
      throw err if err
      result.dn.should.match /^cn=admins,cn=groups,cn=accounts,/
    .promise()

  they 'get missing group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.show
      principal: 'admin'
      password: 'admin_pw'
      referer: 'https://ipa.nikita/ipa'
      url: 'https://ipa.nikita/ipa/session/json'
      cn: 'missing'
      relax: true
    , (err, {code, result}) ->
      err.code.should.eql 4001
      err.message.should.eql 'missing: group not found'
    .promise()
