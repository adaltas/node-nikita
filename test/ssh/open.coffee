
nikita = require '../../src'
ssh = require '../../src/misc/ssh'
test = require '../test'
connect = require 'ssh2-connect'

describe 'ssh.open', ->

  scratch = test.scratch @

  it 'with handler options', ->
    config = test.config()
    nikita
    .call (options) ->
      (!!@ssh()).should.be.false()
    .ssh.open
      host: config.ssh.host
      port: config.ssh.port
      username: config.ssh.username
      password: config.ssh.password
      private_key: config.ssh.privateKey
      public_key: config.ssh.publicKey
    , (err, status) ->
      status.should.be.true() unless err
    .call (options) ->
      (!!@ssh()).should.be.true()
      ssh.is( @ssh() ).should.be.true()
    .ssh.close()
    .promise()

  it 'with global options', ->
    config = test.config()
    nikita
      ssh:
        host: config.ssh.host
        port: config.ssh.port
        username: config.ssh.username
        password: config.ssh.password
        private_key: config.ssh.privateKey
        public_key: config.ssh.publicKey
    .ssh.open()
    .call (options) ->
      (!!@ssh()).should.be.true()
      ssh.is( @ssh() ).should.be.true()
    .ssh.close {}, (err, status) ->
      status.should.be.true() unless err
    .ssh.close {}, (err, status) ->
      status.should.be.false() unless err
    .promise()

  it 'check status with properties', ->
    config = test.config()
    options = 
      host: config.ssh.host
      port: config.ssh.port
      username: config.ssh.username
      password: config.ssh.password
      private_key: config.ssh.privateKey
      public_key: config.ssh.publicKey
    nikita
    .ssh.open options
    .ssh.open options, (err, status) ->
      status.should.be.false() unless err
    .ssh.close()
    .promise()

  it 'check status with instance', (next) ->
    config = test.config()
    connect
      host: config.ssh.host
      port: config.ssh.port
      username: config.ssh.username
      password: config.ssh.password
      private_key: config.ssh.privateKey
      public_key: config.ssh.publicKey
    , (err, ssh) ->
      return next err if err
      nikita
      .ssh.open ssh: ssh, (err, status) ->
        status.should.eql true unless err
      .ssh.open ssh: ssh, (err, status) ->
        status.should.be.false() unless err
      .ssh.close()
      .next (err) ->
        ssh.end()
        next err
