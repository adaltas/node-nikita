
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'ssh.close', ->

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

  they 'argument does not conflict with session', (ssh) ->
    return @skip() unless ssh
    nikita
      ssh: 
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey.privateOrig
        public_key: ssh.config.publicKey.publicOrig
    .ssh.open()
    .call ->
      misc.ssh.is(@ssh true).should.be.true()
    .call ->
      (@ssh(false) is null).should.be.true()
    .ssh.close()
    .promise()
