
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter (ssh) -> !!ssh

return unless tags.posix

describe 'ssh.index', ->

  they.skip 'options ssh true with an active connection', ({ssh}) ->
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
    .call ->
      utils.ssh.is(@ssh true).should.be.true()
    .ssh.close()
    .promise()

  they.skip 'argument is false with an active connection', ({ssh}) ->
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
    .call ->
      (@ssh(false) is null).should.be.true()
    .ssh.close()
    .promise()

  they.skip 'argument is false without an active connection', ({ssh}) ->
    nikita.ssh false
    .should.be.resolvedWith(ssh: null)

  they.skip 'argument does not conflict with session', ({ssh}) ->
    nikita
      ssh:
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
    .ssh.open()
    .call ->
      utils.ssh.is(@ssh true).should.be.true()
    .call ->
      (@ssh(false) is null).should.be.true()
    .ssh.close()
    .promise()
