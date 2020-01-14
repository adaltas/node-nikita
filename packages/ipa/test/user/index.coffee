
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.user', ->
  
  it 'schema root properties', ->
    nikita
    .ipa.user
      relax: true
      uid: [1,2,3]
    , (err) ->
      err.errors
      .map (err) -> err.message
      .should.eql [
        'data.uid should be string'
        'data should have required property \'attributes\''
        'data should have required property \'connection\''
      ]
    .promise()

  it 'schema connection properties', ->
    nikita
    .ipa.user
      relax: true
      uid: 'username'
      attributes: {}
      connection: principal: [1,2,3]
    , (err) ->
      err.errors
      .map (err) -> err.message
      .should.eql [
        'data.connection.principal should be string'
        'data.connection should have required property \'url\''
      ]
    .promise()

  they 'create a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del connection: ipa,
      uid: 'user_add'
    .ipa.user connection: ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.user connection: ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'modify a user', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.user.del connection: ipa,
      uid: 'user_add'
    .ipa.user connection: ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname 1'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    .ipa.user connection: ipa,
      uid: 'user_add'
      attributes:
        givenname: 'Firstname 2'
        sn: 'Lastname'
        mail: [ 'user@nikita.js.org' ]
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.user.show connection: ipa,
      uid: 'user_add'
    , (err, {result}) ->
      result.givenname.should.eql ['Firstname 2']
    .promise()
