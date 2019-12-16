
connect = require 'ssh2-connect'
misc = require '../../src/misc'
{tags, ssh} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter( (ssh) -> !!ssh )...

return unless tags.api

describe 'misc ssh', ->

  they 'compare two null', ({ssh}, next) ->
    misc.ssh.compare(null, null).should.be.true()
    misc.ssh.compare(null, false).should.be.true()
    next()

  they 'compare identical instances', ({ssh}, next) ->
    misc.ssh.compare(ssh, ssh).should.be.true()
    next()

  they 'compare an instance with a config', ({ssh}, next) ->
    config =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    misc.ssh.compare(config, ssh).should.be.true()
    next()

  they 'compare a config with an instance', ({ssh}, next) ->
    config =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    misc.ssh.compare(ssh, config).should.be.true()
    next()
