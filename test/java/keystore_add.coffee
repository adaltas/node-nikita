
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'java.keystore_add', ->

  scratch = test.scratch @

  describe 'cacert', ->

    they 'create new cacerts file', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, status) ->
        status.should.be.true() unless err
      .then next

    they 'create parent directory', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/a/dir/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, status) ->
        status.should.be.true() unless err
      .then next

    they 'detect existing cacert signature', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, status) ->
        status.should.be.false() unless err
      .then next

    they 'update a new cacert with same alias', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs2/cacert.pem"
      , (err, status) ->
        status.should.be.true() unless err
      .then next

  describe 'key', ->

    they 'create new cacerts file', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, status) ->
        status.should.be.true() unless err
      .then next

    they 'detect existing cacert signature', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, status) ->
        status.should.be.false() unless err
      .then next

    they 'update a new cacert with same alias', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        key: "#{__dirname}/keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs2/cacert.pem"
        key: "#{__dirname}/keystore/certs2/node_1_key.pem"
        cert: "#{__dirname}/keystore/certs2/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      , (err, status) ->
        status.should.be.true() unless err
      .then next

  describe 'keystore', ->

    they.skip 'change password', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changednow"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, status) ->
        status.should.be.true() unless err
      .then next
  
  describe 'option openssl', ->
    
    they 'throw error if not detected', (ssh, next) ->
      nikita
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
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
      .then next
    
