
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'java.keystore_add', ->

  describe 'cacert', ->

    they 'create new cacerts file', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

    they 'create parent directory', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/a/dir/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

    they 'detect existing cacert signature', ({ssh}) ->
      nikita
        ssh: null
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'update a new cacert with same alias', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs2/cacert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .system.execute.assert
        cmd: "keytool -list -keystore #{scratch}/keystore -storepass changeit -alias my_alias"
        content: /^my_alias,/m
      .promise()

    they 'fail if ca file does not exist', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: '/path/to/missing/ca.cert.pem'
        relax: true
      , (err) ->
        err.message.should.eql 'CA file does not exist: /path/to/missing/ca.cert.pem'
      .promise()

    they 'import certificate chain', ({ssh}) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        mkdir #{scratch}/tmp
        cd #{scratch}/tmp
        openssl req -new -nodes -out ca_int1.req -keyout ca_int1.key.pem -subj /CN=CAIntermediate1 -newkey rsa:2048 -sha512
        openssl x509 -req -in ca_int1.req -CAkey #{__dirname}/keystore/certs1/cacert_key.pem -CA #{__dirname}/keystore/certs1/cacert.pem -days 20 -set_serial 01 -sha512 -out ca_int1.cert.pem
        openssl req -new -nodes -out ca_int2.req -keyout ca_int2.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
        openssl x509 -req -in ca_int2.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2.cert.pem
        cat #{__dirname}/keystore/certs1/cacert.pem ca_int1.cert.pem ca_int2.cert.pem > ca.cert.pem
        """
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{scratch}/tmp/ca.cert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{scratch}/tmp/ca.cert.pem"
      , (err, {status}) ->
        status.should.be.false() unless err
      .system.execute.assert
        cmd: "keytool -list -keystore #{scratch}/keystore -storepass changeit -alias my_alias-0"
        content: /^my_alias-0,/m
      .system.execute.assert
        cmd: "keytool -list -keystore #{scratch}/keystore -storepass changeit -alias my_alias-1"
        content: /^my_alias-1,/m
      .system.execute.assert
        cmd: "keytool -list -keystore #{scratch}/keystore -storepass changeit -alias my_alias-2"
        content: /^my_alias-2,/m
      .promise()

    they 'honors status with certificate chain', ({ssh}) ->
      nikita
        ssh: ssh
      .system.execute
        cmd: """
        mkdir #{scratch}/ca
        cd #{scratch}/ca
        openssl req -new -nodes -out ca_int1.req -keyout ca_int1.key.pem -subj /CN=CAIntermediate1 -newkey rsa:2048 -sha512
        openssl x509 -req -in ca_int1.req -CAkey #{__dirname}/keystore/certs1/cacert_key.pem -CA #{__dirname}/keystore/certs1/cacert.pem -days 20 -set_serial 01 -sha512 -out ca_int1.cert.pem
        openssl req -new -nodes -out ca_int2a.req -keyout ca_int2a.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
        openssl x509 -req -in ca_int2a.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2a.cert.pem
        cat #{__dirname}/keystore/certs1/cacert.pem ca_int1.cert.pem ca_int2a.cert.pem > ca.a.cert.pem
        openssl req -new -nodes -out ca_int2b.req -keyout ca_int2b.key.pem -subj /CN=CAIntermediate2 -newkey rsa:2048 -sha512
        openssl x509 -req -in ca_int2b.req -CAkey ca_int1.key.pem -CA ca_int1.cert.pem -days 20 -set_serial 01 -sha512 -out ca_int2b.cert.pem
        cat #{__dirname}/keystore/certs1/cacert.pem ca_int1.cert.pem ca_int2b.cert.pem > ca.b.cert.pem
        """
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{scratch}/ca/ca.a.cert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{scratch}/ca/ca.b.cert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

  describe 'key', ->

    they 'create new cacerts file', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

    they 'detect existing cacert signature', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, {status}) ->
        status.should.be.true() unless err
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

    they 'update a new cacert with same alias', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs2/cacert.pem"
        key: "#{__dirname}/keystore/certs2/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs2/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

  describe 'keystore', ->

    they.skip 'change password', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changednow"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()
  
  describe 'option openssl', ->

    they 'throw error if not detected', ({ssh}) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs2/cacert.pem"
        key: "#{__dirname}/keystore/certs2/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs2/node_1_cert.pem"
        keypass: 'mypassword'
        openssl: '/doesnt/not/exists'
        name: 'node_1'
        relax: true
      , (err) ->
        err.message.should.eql 'OpenSSL command line tool not detected'
      .promise()
