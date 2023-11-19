
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.startup', ->
  return unless test.tags.service_startup
  
  describe 'startup', ->

    they 'from service', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: true
        $status.should.be.true()
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: true
        $status.should.be.false()
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: false
        $status.should.be.true()
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: false
        $status.should.be.false()

    they 'string argument', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service.install test.service.name
        await @service.startup
          startup: false
          name: test.service.chk_name
        {$status} = await @service.startup test.service.chk_name
        $status.should.be.true()
