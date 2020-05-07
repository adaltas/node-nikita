
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, ssh} = require '../../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter (ssh) -> !!ssh

return unless tags.posix

describe 'actions.ssh.index', ->
  
  describe 'active connection', ->

    they 'config ssh `true`', ({ssh}) ->
      nikita
      .ssh.open
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
      .call ->
        conn = await @ssh true
        utils.ssh.is(conn).should.be.true()
      .ssh.close()

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
        
  describe 'inactive connection', ->

    they 'argument is `undefined` and no active connection', ({ssh}) ->
      nikita.ssh().should.be.resolvedWith undefined

    they 'argument is `true` and no active connection', ({ssh}) ->
      nikita.ssh(true).should.be.rejectedWith code: 'SSH_UNAVAILABLE_CONNECTION'

    they 'argument is `false` without an active connection', ({ssh}) ->
      nikita.ssh(false).should.be.resolvedWith undefined

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
