
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.remove', ->
  return unless test.tags.service_install

  they 'package is not installed', ({ssh, sudo}) ->
    {$status} = await nikita
      $ssh: ssh
      $sudo: sudo
    .service.remove
      name: 'XXXX'
    $status.should.be.false()


  they 'new package', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @service.install
        name: test.service.name
      {$status} = await @service.remove
        name: test.service.name
      $status.should.be.true()
      {$status} = await @service.remove
        name: test.service.name
      $status.should.be.false()
