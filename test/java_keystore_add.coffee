
mecano = require "../src"
they = require 'ssh2-they'
test = require './test'

describe 'java_keystore_add', ->

  scratch = test.scratch @

  describe 'cacert', ->

    they 'create new cacerts file', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
      .then (err, status) ->
        status.should.be.true() unless err
        next err

    they 'detect existing cacert signature', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        shy: true
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
      .then (err, status) ->
        status.should.be.false() unless err
        next err

    they 'update a new cacert with same alias', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        shy: true
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs2/cacert.pem"
      .then (err, status) ->
        status.should.be.true() unless err
        next err

  describe 'cert', ->

    they 'create new cacerts file', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        key: "#{__dirname}/java_keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/java_keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      .then (err, status) ->
        status.should.be.true() unless err
        next err

    they 'detect existing cacert signature', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        key: "#{__dirname}/java_keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/java_keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
        shy: true
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        key: "#{__dirname}/java_keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/java_keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      .then (err, status) ->
        status.should.be.false() unless err
        next err

    they 'update a new cacert with same alias', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        key: "#{__dirname}/java_keystore/certs1/node_1_key.pem"
        cert: "#{__dirname}/java_keystore/certs1/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
        shy: true
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs2/cacert.pem"
        key: "#{__dirname}/java_keystore/certs2/node_1_key.pem"
        cert: "#{__dirname}/java_keystore/certs2/node_1_cert.pem"
        keypass: 'mypassword'
        name: 'node_1'
      .then (err, status) ->
        status.should.be.true() unless err
        next err

  describe 'keystore', ->

    they.skip 'change password', (ssh, next) ->
      mecano
        ssh: ssh
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
        shy: true
      .java_keystore_add
        keystore: "#{scratch}/cacerts"
        storepass: "changednow"
        caname: "my_alias"
        cacert: "#{__dirname}/java_keystore/certs1/cacert.pem"
      .then (err, status) ->
        status.should.be.true() unless err
        next err
