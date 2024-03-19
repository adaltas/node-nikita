
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)
__dirname = new URL( '.', import.meta.url).pathname

describe 'java.keystore.add', ->
  return unless test.tags.java
  
  describe 'schema', ->
    
    it 'cacert implies caname', ->
      await nikita.java.keystore.add
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        cacert: "ok"
        caname: 'ok'
      await nikita.java.keystore.add
        keystore: "ok"
        storepass: "ok"
        cacert: "implies caname"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `java.keystore.add`:'
        '#/dependentRequired config must have property caname when property cacert is present,'
        'property is "cacert", depsCount is 1, deps is "caname".'
      ].join ' '
        
    it 'cert implies key, keypass and name', ->
      await nikita.java.keystore.add
        $handler: (->)
        keystore: "ok"
        storepass: "ok"
        cert: "ok"
        key: "ok"
        keypass: "ok"
        name: 'ok'
      await nikita.java.keystore.add
        keystore: "ok"
        storepass: "ok"
        cert: "implies key, keypass and name"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'multiple errors were found in the configuration of action `java.keystore.add`:'
        '#/dependentRequired config must have properties key, keypass, name when property cert is present,'
        'property is "cert", depsCount is 3, deps is "key, keypass, name";'
        '#/dependentRequired config must have properties key, keypass, name when property cert is present,'
        'property is "cert", depsCount is 3, deps is "key, keypass, name";'
        '#/dependentRequired config must have properties key, keypass, name when property cert is present,'
        'property is "cert", depsCount is 3, deps is "key, keypass, name".'
      ].join ' '
  
  describe 'config', ->

    they 'caname, cacert, cert, name, key, keypass are provided', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_caname"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
          cert: "#{__dirname}/../resources/certs1/node_1_cert.pem"
          name: "my_name"
          key: "#{__dirname}/../resources/certs1/node_1_key.pem"
          keypass: 'mypassword'
        $status.should.be.true()

  describe 'cacert', ->

    they 'create new cacerts file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        $status.should.be.true()

    they 'create parent directory', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/a/dir/cacerts"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        $status.should.be.true()

    they 'detect existing cacert signature', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore.add
          $shy: true
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        $status.should.be.false()

    they 'update a new cacert with same alias', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore.add
          $shy: true
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs2/cacert.pem"
        $status.should.be.true()
        await @java.keystore.exists
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          name: "my_alias"
        .then(({exists}) => exists)
        .should.be.finally.equal true


    they 'fail if CA file does not exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: '/path/to/missing/ca.cert.pem'
        .should.be.rejectedWith
          message: 'CA file does not exist: /path/to/missing/ca.cert.pem'

    they 'import certificate chain', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute
          command: """
          mkdir #{tmpdir}/tmp
          cd #{tmpdir}/tmp
          # Generate 1st intermediate certificate key and CSR ("ca_int1.key.pem" and "ca_int1.req")
          openssl req -new -nodes -out ca_int1.req -keyout ca_int1.key.pem -subj /CN=CAIntermediate1 -newkey rsa:2048 -sha512
          # Sign 1st intermediate certificate with certs1 ("ca_int1.cert.pem")
          openssl x509 -req -in ca_int1.req -CAkey #{__dirname}/../resources/certs1/cacert_key.pem -CA #{__dirname}/../resources/certs1/cacert.pem -days 20 -set_serial 01 -sha512 -out ca_int1.cert.pem
          # Generate 2nd intermediate certificate key and CSR ("ca_int2.key.pem" and "ca_int2.req")
          openssl req -new -nodes -out ca_int2.req -keyout ca_int2.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
          # Sign 2nd intermediate certificate with 1st intermediate certificate ("ca_int2.cert.pem")
          openssl x509 -req -in ca_int2.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2.cert.pem
          cat #{__dirname}/../resources/certs1/cacert.pem ca_int1.cert.pem ca_int2.cert.pem > ca.cert.pem
          """
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/tmp/ca.cert.pem"
        $status.should.be.true()
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/tmp/ca.cert.pem"
        $status.should.be.false()
        await @java.keystore.exists
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          name: "my_alias-0"
        .then(({exists}) => exists)
        .should.be.finally.equal true
        await @java.keystore.exists
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          name: "my_alias-1"
        .then(({exists}) => exists)
        .should.be.finally.equal true
        await @java.keystore.exists
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          name: "my_alias-2"
        .then(({exists}) => exists)
        .should.be.finally.equal true

    they 'honors status with certificate chain', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @execute
          command: """
          mkdir #{tmpdir}/ca
          cd #{tmpdir}/ca
          openssl req -new -nodes -out ca_int1.req -keyout ca_int1.key.pem -subj /CN=CAIntermediate1 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int1.req -CAkey #{__dirname}/../resources/certs1/cacert_key.pem -CA #{__dirname}/../resources/certs1/cacert.pem -days 20 -set_serial 01 -sha512 -out ca_int1.cert.pem
          openssl req -new -nodes -out ca_int2a.req -keyout ca_int2a.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int2a.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2a.cert.pem
          cat #{__dirname}/../resources/certs1/cacert.pem ca_int1.cert.pem ca_int2a.cert.pem > ca.a.cert.pem
          openssl req -new -nodes -out ca_int2b.req -keyout ca_int2b.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
          openssl x509 -req -in ca_int2b.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2b.cert.pem
          cat #{__dirname}/../resources/certs1/cacert.pem ca_int1.cert.pem ca_int2b.cert.pem > ca.b.cert.pem
          """
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/ca/ca.a.cert.pem"
        $status.should.be.true()
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{tmpdir}/ca/ca.b.cert.pem"
        $status.should.be.true()

  describe 'key', ->

    they 'create new cacerts file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
          key: "#{__dirname}/../resources/certs1/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.true()

    they 'detect existing cacert signature', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
          key: "#{__dirname}/../resources/certs1/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.true()
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
          key: "#{__dirname}/../resources/certs1/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.false()

    they 'update a new cacert with same alias', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
          key: "#{__dirname}/../resources/certs1/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs1/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs2/cacert.pem"
          key: "#{__dirname}/../resources/certs2/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs2/node_1_cert.pem"
          keypass: 'mypassword'
          name: 'node_1'
        $status.should.be.true()

  describe 'keystore', ->

    they.skip 'change password', ({ssh}) ->
      nikita
        $ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        {$status} = await @java.keystore.add
          keystore: "#{tmpdir}/resources"
          storepass: "changednow"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs1/cacert.pem"
        $status.should.be.true()

  describe 'config openssl', ->

    they 'throw error if not detected', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @java.keystore.add
          keystore: "#{tmpdir}/keystore"
          storepass: "changeit"
          caname: "my_alias"
          cacert: "#{__dirname}/../resources/certs2/cacert.pem"
          key: "#{__dirname}/../resources/certs2/node_1_key.pem"
          cert: "#{__dirname}/../resources/certs2/node_1_cert.pem"
          keypass: 'mypassword'
          openssl: '/doesnt/not/exists'
          name: 'node_1'
        .should.be.rejectedWith
          message: 'OpenSSL command line tool not detected.'
