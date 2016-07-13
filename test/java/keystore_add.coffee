
mecano = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'java.keystore_add', ->

  scratch = test.scratch @

  describe 'cacert', ->

    they 'create new cacerts file', (ssh, next) ->
      mecano
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      , (err, status) ->
        status.should.be.true() unless err
      .then (err, status) ->
        status.should.be.true() unless err
        next err

    they 'detect existing cacert signature', (ssh, next) ->
      mecano
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
      .then (err, status) ->
        status.should.be.false() unless err
        next err

    they 'update a new cacert with same alias', (ssh, next) ->
      mecano
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
      .then (err, status) ->
        status.should.be.true() unless err
        next err

  describe 'key', ->

    they 'create new cacerts file', (ssh, next) ->
      mecano
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
      .then (err, status) ->
        status.should.be.true() unless err
        next err

    they 'detect existing cacert signature', (ssh, next) ->
      mecano
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
      .then (err, status) ->
        status.should.be.false() unless err
        next err

    they 'update a new cacert with same alias', (ssh, next) ->
      mecano
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
      .then (err, status) ->
        status.should.be.true() unless err
        next err

  describe 'keystore', ->

    they.skip 'change password', (ssh, next) ->
      mecano
        ssh: ssh
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
        shy: true
      .java.keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changednow"
        caname: "my_alias"
        cacert: "#{__dirname}/keystore/certs1/cacert.pem"
      .then (err, status) ->
        status.should.be.true() unless err
        next err
