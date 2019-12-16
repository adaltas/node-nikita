
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter( (ssh) -> !!ssh )...

return unless tags.posix

describe 'ssh.index', ->

  they 'argument is true', ({ssh}) ->
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
    .call ->
      misc.ssh.is(@ssh true).should.be.true()
    .ssh.close()
    .promise()

  they 'argument is false', ({ssh}) ->
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

  they 'argument does not conflict with session', ({ssh}) ->
    nikita
      ssh:
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
    .ssh.open()
    .call ->
      misc.ssh.is(@ssh true).should.be.true()
    .call ->
      (@ssh(false) is null).should.be.true()
    .ssh.close()
    .promise()
