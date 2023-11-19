
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.status', ->
  return unless test.tags.service_systemctl
  
  they 'store status', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service
        name: test.service.name
      await @service.stop
        name: test.service.srv_name
      {started} = await @service.status
        name: test.service.srv_name
      started.should.be.false()
      await @service.start
        name: test.service.srv_name
      {started} = await @service.status
        name: test.service.srv_name
      started.should.be.true()
      await @service.stop
        name: test.service.srv_name
      {started} = await @service.status
        name: test.service.name
        srv_name: test.service.srv_name
      started.should.be.false()
