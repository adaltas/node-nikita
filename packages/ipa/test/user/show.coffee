
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

ipa =
  principal: 'admin'
  password: 'admin_pw'
  referer: 'https://ipa.nikita/ipa'
  url: 'https://ipa.nikita/ipa/session/json'

describe 'ipa.user.show', ->

  they 'get single user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.show ipa,
      uid: 'admin'
    , (err, {result}) ->
      throw err if err
      result.dn.should.match /^uid=admin,cn=users,cn=accounts,/
    .promise()

  they 'get missing user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.show ipa,
      uid: 'missing'
      relax: true
    , (err, {code, result}) ->
      err.code.should.eql 4001
      err.message.should.eql 'missing: user not found'
    .promise()
