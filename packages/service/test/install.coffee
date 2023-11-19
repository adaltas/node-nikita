
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.install', ->
  return unless test.tags.service_install

  they 'new package', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @service.remove
        name: test.service.name
      {$status} = await @service
        name: test.service.name
      $status.should.be.true()
  
  they 'already installed packages', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @service.remove
        name: test.service.name
      await @service
        name: test.service.name
      {$status} = await @service
        name: test.service.name
      $status.should.be.false()

  they 'name as default argument', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @service.remove
        name: test.service.name
      {$status} = await @service test.service.name
      $status.should.be.true()
  
  they.skip 'update package list in cache', ({ssh, sudo}) ->
    # Cache is not yet implemented, it needs some reflexion on how to make this
    # work accross multiple ssh connections
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @service.remove
        name: test.service.name
      await @call ({parent: {state}}) ->
        (state['nikita:service:packages:installed'] is undefined).should.be.true()
      {$status} = await @service
        name: test.service.name
        cache: true
      $status.should.be.true()
      await @call ({parent: {state}}) ->
        state['nikita:service:packages:installed'].should.containEql test.service.name

  they 'throw error if not exists', ({ssh, sudo}) ->
    nikita.service.install
      $ssh: ssh
      $sudo: sudo
      name: 'thisservicedoesnotexist'
    .should.be.rejectedWith
      code: 'NIKITA_SERVICE_INSTALL'
      message: [
        'NIKITA_SERVICE_INSTALL:'
        'failed to install package,'
        'name is "thisservicedoesnotexist"'
      ].join ' '

  they 'option `code`', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      {$status} = await @service.install
        name: 'thisservicedoesnotexist'
        code: [0, [1, 100]] # 1 for RHEL, 100 for Ubuntu
      $status.should.be.false()
