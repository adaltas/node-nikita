
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.user.remove', ->
  
  describe 'schema', ->
    return unless test.tags.api
    
    it 'default argument', ->
      {config} = await nikita.system.user.remove 'toto', ({config}) ->
        config: config
      config.name.should.eql 'toto'
      
  describe 'usage', ->
    return unless test.tags.system_user
  
    they 'handle status', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @system.user.remove 'toto'
        await @system.group.remove 'toto'
        await @system.user 'toto'
        {$status} = await @system.user.remove 'toto'
        $status.should.be.true()
        {$status} = await @system.user.remove 'toto'
        $status.should.be.false()
