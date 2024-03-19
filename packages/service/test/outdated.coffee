
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.outdated', ->
  return unless test.tags.service_outdated
  
  they 'list all packages', ({ssh, sudo}) ->
    {packages, outdated} = await nikita.service.outdated
      $ssh: ssh
      $sudo: sudo
    should(outdated).be.undefined()
    packages.should.matchEach (it) -> it.should.be.a.String()
  
  they 'test outdated package', ({ssh, sudo}) ->
    {packages, outdated} = await nikita
      $ssh: ssh
      $sudo: sudo
    .service.outdated
      name: test.service.name
    should(packages).be.undefined()
    outdated.should.be.true()
  
  they 'test not-installed package', ({ssh, sudo}) ->
    {packages, outdated} = await nikita
      $ssh: ssh
      $sudo: sudo
    .service.outdated
      name: 'XXXX'
    should(packages).be.undefined()
    outdated.should.be.false()
