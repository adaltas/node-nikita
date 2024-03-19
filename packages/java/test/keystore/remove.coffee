
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)
__dirname = new URL( '.', import.meta.url).pathname

describe 'java.keystore.remove', ->
  return unless test.tags.java
  
  describe 'schema and config', ->
    
    it 'either name of cname is required', ->
      await nikita.java.keystore.remove
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        caname: "ok"
      .should.be.fulfilled()
      await nikita.java.keystore.remove
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        name: "ok"
      .should.be.fulfilled()
      await nikita.java.keystore.remove
        keystore: "ok"
        storepass: "ok"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'multiple errors were found in the configuration of action `java.keystore.remove`:'
        '#/definitions/config/anyOf config must match a schema in anyOf;'
        '#/definitions/config/anyOf/0/required config must have required property \'name\';'
        '#/definitions/config/anyOf/1/required config must have required property \'caname\'.'
      ].join ' '

    they 'keystore doesnt need to exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore.remove
          keystore: "#{tmpdir}/does/not/exist"
          storepass: "invalid"
          caname: "invalid"
        $status.should.be.false()
          
    they 'caname and name are provided', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @java.keystore.remove
          keystore: "invalid"
          storepass: "invalid"
          caname: "my_caname"
          name: "my_name"

  describe 'cacert', ->

    they 'remove cacerts', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore.add
          keystore: "#{tmpdir}/cacerts"
          storepass: 'changeit'
          caname: 'my_alias'
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        {$status} = await @java.keystore.remove
          keystore: "#{tmpdir}/cacerts"
          storepass: 'changeit'
          caname: 'my_alias'
        $status.should.be.true()
        {$status} = await @java.keystore.remove
          keystore: "#{tmpdir}/cacerts"
          storepass: 'changeit'
          caname: 'my_alias'
        $status.should.be.false()
        await @java.keystore.exists
          keystore: "#{tmpdir}/cacerts"
          storepass: "changeit"
          name: "my_alias"
        .then(({exists}) => exists)
        .should.be.finally.equal false

  describe 'key', ->

    they 'remove cacerts file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore.add
          keystore: "#{tmpdir}/cacerts"
          storepass: 'changeit'
          caname: 'my_alias'
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
          key: "#{__dirname}/../resources/certs1/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        {$status} = await @java.keystore.remove
          keystore: "#{tmpdir}/cacerts"
          storepass: 'changeit'
          name: 'node_1'
        $status.should.be.true()
        {$status} = await @java.keystore.remove
          keystore: "#{tmpdir}/cacerts"
          storepass: 'changeit'
          name: 'node_1'
        $status.should.be.false()
        await @java.keystore.exists
          keystore: "#{tmpdir}/cacerts"
          storepass: "changeit"
          name: "node_1"
        .then(({exists}) => exists)
        .should.be.finally.equal false
