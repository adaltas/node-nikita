
utils = require '../../src/utils'
{tags, ssh} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter (ssh) -> !!ssh

describe 'utils ssh', ->

  they 'compare two null', ({ssh}) ->
    utils.ssh.compare(null, null).should.be.true()
    utils.ssh.compare(null, false).should.be.true()

  they 'compare identical instances', ({ssh}) ->
    utils.ssh.compare(ssh, ssh).should.be.true()

  they 'compare an instance with a config', ({ssh}) ->
    config =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    utils.ssh.compare(config, ssh.config).should.be.true()

  they 'compare a config with an instance', ({ssh}) ->
    config =
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey
      public_key: ssh.config.publicKey
    utils.ssh.compare(config, ssh).should.be.true()
