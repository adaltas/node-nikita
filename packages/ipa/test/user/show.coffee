
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.user.show', ->

  they 'get single user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.show connection: ipa,
      uid: 'admin'
    , (err, {result}) ->
      throw err if err
      result.dn.should.match /^uid=admin,cn=users,cn=accounts,/
    .promise()

  they 'get missing user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.show connection: ipa,
      uid: 'missing'
      relax: true
    , (err, {result}) ->
      err.code.should.eql 4001
      err.message.should.eql 'missing: user not found'
    .promise()
