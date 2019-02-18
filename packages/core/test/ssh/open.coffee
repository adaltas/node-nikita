
connect = require 'ssh2-connect'
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'ssh.open', ->

  they 'with handler options', ({ssh}) ->
    return @skip() unless ssh
    nikita
    .call ->
      (!!@ssh()).should.be.false()
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    , (err, {status}) ->
      status.should.be.true() unless err
    .call ->
      (!!@ssh()).should.be.true()
      misc.ssh.is( @ssh() ).should.be.true()
    .ssh.close()
    .promise()

  they 'with global options', ({ssh}) ->
    return @skip() unless ssh
    nikita
      ssh:
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
        public_key: ssh.config.publicKey
    .ssh.open()
    .call ->
      (!!@ssh()).should.be.true()
      misc.ssh.is( @ssh() ).should.be.true()
    .ssh.close {}, (err, {status}) ->
      status.should.be.true() unless err
    .ssh.close {}, (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'check status with properties', ({ssh}) ->
    return @skip() unless ssh
    options =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    nikita
    .ssh.open options
    .ssh.open options, (err, {status}) ->
      status.should.be.false() unless err
    .ssh.close()
    .promise()

  they 'check status with instance', ({ssh}, next) ->
    return @skip() unless ssh
    connect
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    , (err, ssh) ->
      return next err if err
      nikita
      .ssh.open ssh: ssh, (err, {status}) ->
        status.should.eql true unless err
      .ssh.open ssh: ssh, (err, {status}) ->
        status.should.be.false() unless err
      .ssh.close()
      .next (err) ->
        ssh.end()
        next err
