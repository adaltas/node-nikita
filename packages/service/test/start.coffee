
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.start', ->
  return unless test.tags.service_systemctl
  
  they 'should start', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service
        name: test.service.name
      await @service.stop
        name: test.service.srv_name
      {$status} = await @service.start
        name: test.service.srv_name
      $status.should.be.true()
      {started} = await @service.status
        name: test.service.srv_name
      started.should.be.true()
      {$status} = await @service.start # Detect already started
        name: test.service.srv_name
      $status.should.be.false()
  
  they 'no error when invalid service name', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @service.start
        name: 'thisdoenstexit'
      $status.should.be.false()
