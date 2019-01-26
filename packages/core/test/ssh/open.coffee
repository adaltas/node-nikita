
connect = require 'ssh2-connect'
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
{tags, ssh} = require '../test'

return unless tags.posix

describe 'ssh.open', ->

  it 'with handler options', ->
    nikita
    .call ->
      (!!@ssh()).should.be.false()
    .ssh.open
      host: ssh.host
      port: ssh.port
      username: ssh.username
      password: ssh.password
      private_key: ssh.privateKey
      public_key: ssh.publicKey
    , (err, {status}) ->
      status.should.be.true() unless err
    .call ->
      (!!@ssh()).should.be.true()
      misc.ssh.is( @ssh() ).should.be.true()
    .ssh.close()
    .promise()

  it 'with global options', ->
    nikita
      ssh:
        host: ssh.host
        port: ssh.port
        username: ssh.username
        password: ssh.password
        private_key: ssh.privateKey
        public_key: ssh.publicKey
    .ssh.open()
    .call ->
      (!!@ssh()).should.be.true()
      misc.ssh.is( @ssh() ).should.be.true()
    .ssh.close {}, (err, {status}) ->
      status.should.be.true() unless err
    .ssh.close {}, (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  it 'check status with properties', ->
    options = 
      host: ssh.host
      port: ssh.port
      username: ssh.username
      password: ssh.password
      private_key: ssh.privateKey
      public_key: ssh.publicKey
    nikita
    .ssh.open options
    .ssh.open options, (err, {status}) ->
      status.should.be.false() unless err
    .ssh.close()
    .promise()

  it 'check status with instance', (next) ->
    connect
      host: ssh.host
      port: ssh.port
      username: ssh.username
      password: ssh.password
      private_key: ssh.privateKey
      public_key: ssh.publicKey
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
