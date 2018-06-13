
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'ssh.open', ->

  scratch = test.scratch @

  they 'with handler options', (ssh) ->
    return @skip() unless ssh
    nikita
    .call (options) ->
      (!!@ssh()).should.be.false()
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
      (!!@ssh()).should.be.true()
      # Note, assert instance of SSH2 which isnt a direct dependency
      @ssh()._sshstream.config.ident.should.eql 'SSH-2.0-ssh2js0.2.0'
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
      (!!@ssh()).should.be.true()
      # Note, assert instance of SSH2 which isnt a direct dependency
      @ssh()._sshstream.config.ident.should.eql 'SSH-2.0-ssh2js0.2.0'
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
