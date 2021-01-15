
connect = require 'ssh2-connect'
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, config} = require '../../test'
# All test are executed with an ssh connection passed as an argument
they = require('mocha-they')(config.filter ({ssh}) -> !!ssh)

return unless tags.posix

describe 'actions.ssh.open', ->
  
  describe 'schema', ->
    
    they 'config.host', ({ssh}) ->
      nikita
      .ssh.open {...ssh, host: '_invalid_', debug: undefined}
      .should.be.rejectedWith code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      
  describe 'connection properties', ->

    they 'with handler config', ({ssh}) ->
      nikita ->
        @ssh.open ssh
        .then ({status, ssh}) ->
          status.should.be.true()
          utils.ssh.is( ssh ).should.be.true()
        @ssh.close()

    they 'check status and return connection', ({ssh}) ->
      nikita
      .ssh.open ssh
      .ssh.open ssh
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
        global: ssh: ssh
      .ssh.open()
      .call ->
        @ssh().then ({ssh}) -> utils.ssh.is ssh
      @ssh.close()

    they 'check status with instance', ({ssh}) ->
      conn = await connect ssh
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
      conn = await connect ssh
      nikita
      .ssh.open conn
      .ssh.close()
  
  describe 'errors', ->
    
    they 'NIKITA_SSH_OPEN_UNMATCHING_SSH_INSTANCE', ({ssh}) ->
      conn1 = await connect ssh
      conn2 = await connect ssh
      conn2.config.host = 'something.else' # Fake another connection
      nikita ->
        @ssh.open ssh: conn1
        await @ssh.open ssh: conn2
        .should.be.rejectedWith code: 'NIKITA_SSH_OPEN_UNMATCHING_SSH_INSTANCE'
        @ssh.close ssh: conn1
        @ssh.close ssh: conn2
    
    they 'NIKITA_SSH_OPEN_UNMATCHING_SSH_CONFIG', ({ssh}) ->
      nikita ->
        @ssh.open ssh
        await @ssh.open ssh, host: 'something.else'
        .should.be.rejectedWith code: 'NIKITA_SSH_OPEN_UNMATCHING_SSH_CONFIG'
        @ssh.close()
    
