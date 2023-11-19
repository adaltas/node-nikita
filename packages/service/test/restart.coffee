
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.restart', ->
  return unless test.tags.service_systemctl

  they 'should restart', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service
        name: test.service.name
      await @service.start
        name: test.service.srv_name
      {$status} = await @service.restart
        name: test.service.srv_name
      $status.should.be.true()
