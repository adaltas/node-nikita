
import connect from 'ssh2-connect'
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config.filter( ({ssh}) -> !!ssh))

describe 'actions.ssh.open', ->
  
  describe 'schema', ->
    return unless test.tags.api
    
    they 'config.host', ({ssh}) ->
      nikita
      .ssh.open {...ssh, host: '_invalid_', debug: undefined}
      .should.be.rejectedWith code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      
  describe 'usage', ->
    return unless test.tags.ssh

    they 'from config', ({ssh}) ->
      nikita ->
        {ssh, $status} = await @ssh.open ssh
        utils.ssh.is( ssh ).should.be.true()
        @ssh.close ssh: ssh
    
