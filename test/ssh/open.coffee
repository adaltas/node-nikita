
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'ssh.open', ->

  scratch = test.scratch @

  they 'with handler options', (ssh) ->
    return @skip() unless ssh
    nikita
    .call (options) ->
      (!!options.ssh).should.be.false()
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    , (err, status) ->
      status.should.be.true() unless err
    .call (options) ->
      (!!options.ssh).should.be.true()
    .ssh.close()
    .promise()

  they 'with global options', (ssh) ->
    return @skip() unless ssh
    nikita
      ssh:
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey.privateOrig
        public_key: ssh.config.publicKey.publicOrig
    .call (options) ->
      (!!options.ssh).should.be.true()
      options.ssh.should.be.an.instanceof require('ssh2').Client
    .ssh.close {}, (err, status) ->
      status.should.be.true() unless err
    .ssh.close {}, (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'check status', (ssh) ->
    return @skip() unless ssh
    options = 
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    nikita
    .ssh.open options
    .ssh.open options, (err, status) ->
      status.should.be.false() unless err
    .ssh.close()
    .promise()
