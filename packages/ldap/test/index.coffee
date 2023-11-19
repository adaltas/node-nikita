
import nikita from '@nikitajs/core'
import utils from '@nikitajs/ldap/utils'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.index', ->
  return unless test.tags.ldap_index
  
  olcDatabase = olcDbIndexes = null
  beforeEach ->
    {database: olcDatabase} = await nikita.ldap.tools.database
      uri: test.ldap.uri
      binddn: test.ldap.config.binddn
      passwd: test.ldap.config.passwd
      suffix: test.ldap.suffix_dn
    {stdout} = await nikita.ldap.search
      uri: test.ldap.uri
      binddn: test.ldap.config.binddn
      passwd: test.ldap.config.passwd
      base: "olcDatabase=#{olcDatabase},cn=config"
      attributes:['olcDbIndex']
      scope: 'base'
    olcDbIndexes = utils.string.lines(stdout)
    .filter (l) -> /^olcDbIndex: /.test l
    .map (line) -> line.split(':')[1].trim()
  afterEach ->
    nikita.ldap.modify
      uri: test.ldap.uri
      binddn: test.ldap.config.binddn
      passwd: test.ldap.config.passwd
      operations:
        dn: "olcDatabase=#{olcDatabase},cn=config"
        changetype: 'modify'
        attributes: [
          type: 'delete'
          name: 'olcDbIndex'
          ...(
            type: 'add'
            name: 'olcDbIndex'
            value: olcDbIndex
          ) for olcDbIndex in olcDbIndexes
        ]

  they 'create a new index from dn', ({ssh}) ->
    nikita
      ldap:
        uri: test.ldap.uri
        binddn: test.ldap.config.binddn
        passwd: test.ldap.config.passwd
      $ssh: ssh
    , ->
      {dn} = await @ldap.tools.database
        suffix: test.ldap.suffix_dn
      {$status} = await @ldap.index
        dn: dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.true()
      {$status} = await @ldap.index
        dn: dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.false()

  they 'create a new index from suffix', ({ssh}) ->
    nikita
      ldap:
        uri: test.ldap.uri
        binddn: test.ldap.config.binddn
        passwd: test.ldap.config.passwd
      $ssh: ssh
    , ->
      {$status} = await @ldap.index
        suffix: test.ldap.suffix_dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.true()
      {$status} = await @ldap.index
        suffix: test.ldap.suffix_dn
        indexes:
          aliasedEntryName: 'eq'
      $status.should.be.false()

  they 'update an existing index', ({ssh}) ->
    nikita
      ldap:
        uri: test.ldap.uri
        binddn: test.ldap.config.binddn
        passwd: test.ldap.config.passwd
      $ssh: ssh
    , ->
      # Set initial value
      await @ldap.index
        suffix: test.ldap.suffix_dn
        indexes:
          aliasedEntryName: 'eq'
      # Apply the update
      {$status} = await @ldap.index
        suffix: test.ldap.suffix_dn
        indexes:
          aliasedEntryName: 'pres,eq'
      $status.should.be.true()
      {$status} = await @ldap.index
        suffix: test.ldap.suffix_dn
        indexes:
          aliasedEntryName: 'pres,eq'
      $status.should.be.false()
