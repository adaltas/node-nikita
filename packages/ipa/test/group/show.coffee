
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.group.show', ->

  they 'get single group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.show connection: ipa,
      cn: 'admins'
    , (err, {result}) ->
      throw err if err
      result.gidnumber[0].should.match /\d+/
      result.gidnumber[0] = '0000000000'
      result.should.eql
        dn: 'cn=admins,cn=groups,cn=accounts,dc=nikita,dc=local',
        gidnumber: [ '0000000000' ],
        member_user: [ 'admin' ],
        description: [ 'Account administrators group' ],
        cn: [ 'admins' ]
    .promise()

  they 'get missing group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.show connection: ipa,
      cn: 'missing'
      relax: true
    , (err, {code, result}) ->
      err.code.should.eql 4001
      err.message.should.eql 'missing: group not found'
    .promise()
