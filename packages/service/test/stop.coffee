
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.stop', ->
  return unless test.tags.service_systemctl

  they 'should stop', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service.install test.service.name
      await @service.start test.service.srv_name
      {$status} = await @service.stop test.service.srv_name
      $status.should.be.true()
      {$status} = await @service.stop test.service.srv_name
      $status.should.be.false()

  they 'no error when invalid service name', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @service.stop
        name: 'thisdoenstexit'
      $status.should.be.false()
