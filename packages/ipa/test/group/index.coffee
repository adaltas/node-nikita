
{merge} = require 'mixme'
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.group', ->

  they 'create a group', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del connection: ipa,
      cn: 'group_add'
    .ipa.group connection: ipa,
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.group connection: ipa,
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'attribute option', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del connection: ipa,
      cn: 'group_add'
    .ipa.group connection: ipa,
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.group connection: ipa,
      cn: 'group_add'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'print result such as gidnumber', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del connection: ipa,
      cn: 'group_add'
    .ipa.group connection: ipa,
      cn: 'group_add'
    , (err, {status, result}) ->
      status.should.be.true() unless err
      result.gidnumber.length.should.eql 1
      result = merge result, ipauniqueid: null, gidnumber: null
      result.should.eql
        objectclass: [
          'top'
          'groupofnames'
          'nestedgroup'
          'ipausergroup'
          'ipaobject'
          'posixgroup'
        ]
        dn: 'cn=group_add,cn=groups,cn=accounts,dc=nikita,dc=local'
        gidnumber: null
        cn: [ 'group_add' ]
        ipauniqueid: null
    .promise()

  they 'print result even if no modification is performed', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.group.del connection: ipa,
      cn: 'group_add'
    .ipa.group connection: ipa,
      cn: 'group_add'
    .ipa.group connection: ipa,
      cn: 'group_add'
    , (err, {status, result}) ->
      status.should.be.false() unless err
      result.gidnumber.length.should.eql 1
      result = merge result, ipauniqueid: null, gidnumber: null
      result.should.eql
        dn: 'cn=group_add,cn=groups,cn=accounts,dc=nikita,dc=local'
        gidnumber: null
        cn: [ 'group_add' ]
        ipauniqueid: null
    .promise()
