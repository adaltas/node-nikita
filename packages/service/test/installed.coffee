
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.installed', ->
  return unless test.tags.service_install
  
  they 'list all packages', ({ssh}) ->
    {packages, installed} = await nikita
      $ssh: ssh
    .service.installed
      cache: true
    should(installed).be.undefined()
    packages.should.matchEach (it) -> it.should.be.a.String()
  
  they 'test installed package', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    .service.remove
      name: test.service.name
    .service.install
      name: test.service.name
    .service.installed
      name: test.service.name
    .call ({sibling: {output: {packages, installed}}}) ->
      should(packages).be.undefined()
      installed.should.be.true()
    .service.remove
      name: test.service.name
  
  they 'test not-installed package', ({ssh}) ->
    {packages, installed} = await nikita
      $ssh: ssh
    .service.installed
      name: 'XXXX'
      cache: true
    should(packages).be.undefined()
    installed.should.be.false()
  
  they 'cache package list', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @service.remove
        name: test.service.name
      await @call ({parent: {state}}) ->
        should(state['nikita:service:packages:installed']).be.undefined()
      {$status} = await @service.installed
        name: test.service.name
        cache: true
      $status.should.be.false()
      await @call ({parent: {state}}) ->
        state['nikita:service:packages:installed'].should.be.an.Array()
        state['nikita:service:packages:installed'].should.not.containEql test.service.name
