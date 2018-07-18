
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
misc = require '../../src/misc'

describe 'ssh.close', ->

  scratch = test.scratch @

  they 'argument is true', (ssh) ->
    return @skip() unless ssh
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    .call ->
      misc.ssh.is(@ssh true).should.be.true()
    .ssh.close()
    .promise()

  they 'argument is false', (ssh) ->
    return @skip() unless ssh
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    .call ->
      (@ssh(false) is null).should.be.true()
    .ssh.close()
    .promise()
