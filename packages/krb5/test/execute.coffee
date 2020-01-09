
nikita = require '@nikitajs/core'
{tags, ssh, scratch, krb5} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.krb5

describe 'krb5.execute', ->

  they 'schema', ({ssh}) ->
    nikita
      ssh: ssh
    .krb5.execute
      relax: true
    , (err, {stdout}) ->
      err.errors.map( (err) -> err.message).should.eql [
        'data should have required property \'admin\''
        'data should have required property \'cmd\''
      ]
    .promise()

  they 'global properties', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.execute
      cmd: 'listprincs'
    , (err, {stdout}) ->
      stdout.should.containEql 'kadmin/admin' unless err
    .promise()

  they 'option cmd', ({ssh}) ->
    nikita
      ssh: ssh
    .krb5.execute
      admin: krb5
      cmd: 'listprincs'
    , (err, {stdout}) ->
      stdout.should.containEql 'kadmin/admin' unless err
    .promise()
  
