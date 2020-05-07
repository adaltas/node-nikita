
fs = require 'ssh2-fs'
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter (ssh) -> !!ssh

return unless tags.api

describe '`plugins.ssh`', ->

  they 'from config in root action', ({ssh}) ->
    config =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    nikita ssh: config, ({ssh}) ->
      utils.ssh.compare(ssh, config).should.be.true()

  they 'from config in child action', ({ssh}) ->
    config =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    nikita ssh: config, ({ssh}) ->
      @call -> @call ->
        utils.ssh.compare(ssh, config).should.be.true()

  they 'from connection', ({ssh}) ->
    nikita ssh: ssh, (action) ->
      @call -> @call ->
        utils.ssh.compare(action.ssh, ssh).should.be.true()
