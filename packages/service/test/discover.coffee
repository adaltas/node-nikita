
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.discover', ->
  return unless test.tags.service_install
  
  they 'output loader', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {loader} = await @service.discover()
      loader.should.be.oneOf('systemctl', 'service')
