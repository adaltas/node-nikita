
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
ldap = require 'ldapjs'

describe 'ldap_index', ->

  scratch = test.scratch @
  config = test.config()
  return unless config.ldap
  client = olcDbIndex = null
  beforeEach (next) ->
    client = ldap.createClient url: config.ldap.url
    client.bind config.ldap.binddn, config.ldap.passwd, (err) ->
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

  it 'create a new index', (next) ->
    mecano.ldap_index
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'eq'
    , (err, modified) ->
      return next err if err
      modified.should.eql 1
      mecano.ldap_index
        ldap: client
        name: 'olcDatabase={2}bdb,cn=config'
        indexes:
          aliasedEntryName: 'eq'
      , (err, modified) ->
        return next err if err
        modified.should.eql 0
        next()

  it 'update an existing index', (next) ->
    mecano.ldap_index
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      indexes:
        aliasedEntryName: 'eq'
    , (err, modified) ->
      return next err if err
      modified.should.eql 1
      mecano.ldap_index
        ldap: client
        name: 'olcDatabase={2}bdb,cn=config'
        indexes:
          aliasedEntryName: 'pres,eq'
      , (err, modified) ->
        return next err if err
        modified.should.eql 1
        mecano.ldap_index
          ldap: client
          name: 'olcDatabase={2}bdb,cn=config'
          indexes:
            aliasedEntryName: 'pres,eq'
        , (err, modified) ->
          return next err if err
          modified.should.eql 0
          next()

