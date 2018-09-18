
nikita = require '../../src'
{tags, ssh, ldap} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.ldap_index

describe 'ldap.index', ->
  
  client = olcDbIndex = null
  beforeEach (next) ->
    client = ldap.createClient url: ldap.url
    client.bind ldap.binddn, ldap.passwd, (err) ->
      return next err if err
      client.search 'olcDatabase={2}bdb,cn=config',
        scope: 'base'
        attributes:['olcDbIndex']
      , (err, search) ->
        search.on 'searchEntry', (entry) ->
          olcDbIndex = entry.object.olcDbIndex
        search.on 'end', ->
          next()
  afterEach (next) ->
    change = new ldap.Change
      operation: 'replace'
      modification: olcDbIndex: olcDbIndex
    client.modify 'olcDatabase={2}bdb,cn=config', change, (err) ->
      client.unbind (err) ->
        next err

  it 'create a new index', ->
    nikita
      ldap: client
    .ldap.index
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'eq'
    , (err, {status}) ->
      status.should.be.true()
    .ldap.index
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'eq'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  it 'update an existing index', ->
    nikita
      ldap: client
    .ldap.index
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'eq'
    , (err, {status}) ->
      status.should.be.true()
    .ldap.index
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'pres,eq'
    , (err, {status}) ->
      status.should.be.false()
    .ldap.index
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'pres,eq'
    , (err, {status}) ->
      status.should.be.true()
    .promise()
