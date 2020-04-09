
connect = require 'ssh2-connect'
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter (ssh) -> !!ssh

return unless tags.posix

describe 'ssh.open', ->
  
  describe 'schema', ->
    
    they 'config.host', ({ssh}) ->
      nikita
      .ssh.open {...ssh.config, host: '_invalid_'}
      .should.be.rejectedWith code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      
  describe 'connection properties', ->

    they 'with handler config', ({ssh}) ->
      nikita ->
        @ssh.open
          host: ssh.config.host
          port: ssh.config.port
          username: ssh.config.username
          password: ssh.config.password
          private_key: ssh.config.privateKey
          public_key: ssh.config.publicKey
        .then ({status, ssh}) ->
          status.should.be.true()
          utils.ssh.is( ssh ).should.be.true()
        @ssh.close()

    they 'check status and return connection', ({ssh}) ->
      config =
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
        public_key: ssh.config.publicKey
      nikita
      .ssh.open config
      .ssh.open config
      .call ({sibling, siblings}) ->
        # Status
        siblings
        .map (sibling) -> sibling.output.status
        .should.eql [true, false]
        # Connection
        utils.ssh.is(sibling.output.ssh).should.be.true()
        utils.ssh.compare(...siblings.map((sibling) -> sibling.output.ssh)).should.be.true()
      .ssh.close()
  
  describe 'connection instance', ->

    they.skip 'with global config', ({ssh}) ->
      nikita
        global: ssh:
          host: ssh.config.host
          port: ssh.config.port
          username: ssh.config.username
          password: ssh.config.password
          private_key: ssh.config.privateKey
          public_key: ssh.config.publicKey
      .ssh.open()
      .call ->
        @ssh().then ({ssh}) -> utils.ssh.is ssh
      @ssh.close()

    they 'check status with instance', ({ssh}) ->
      conn = await connect
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
        public_key: ssh.config.publicKey
      nikita
      .ssh.open ssh: conn
      .ssh.open ssh: conn
      .call ({sibling, siblings}) ->
        # Status
        siblings
        .map (sibling) -> sibling.output.status
        .should.eql [true, false]
        # Connection
        utils.ssh.is(sibling.output.ssh).should.be.true()
        utils.ssh.compare(...siblings.map((sibling) -> sibling.output.ssh)).should.be.true()
      .ssh.close()

    they.skip 'directly as the main argument', ({ssh}) ->
      nikita
      .ssh.open ssh
      .ssh.close()
  
  describe 'errors', ->
    
    they.only 'NIKITA_SSH_OPEN_UNMATCHING_SSH_INSTANCE', ({ssh}) ->
      conn = await connect ssh.config
      conn.config.host = 'something.else' # Fake another connection
      nikita ->
        @ssh.open ssh: ssh
        await @ssh.open ssh: conn
        .should.be.rejectedWith code: 'NIKITA_SSH_OPEN_UNMATCHING_SSH_INSTANCE'
        @ssh.close ssh: conn
    
    they 'NIKITA_SSH_OPEN_UNMATCHING_SSH_CONFIG', ({ssh}) ->
      config =
        host: ssh.config.host
        port: ssh.config.port
        username: ssh.config.username
        password: ssh.config.password
        private_key: ssh.config.privateKey
        public_key: ssh.config.publicKey
      nikita ->
        @ssh.open config
        await @ssh.open config, host: 'something.else'
        .should.be.rejectedWith code: 'NIKITA_SSH_OPEN_UNMATCHING_SSH_CONFIG'
        @ssh.close()
    
