
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.rubygems.remove', ->
  return unless test.tags.tools_rubygems

  they 'remove an existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
    , ->
      await @tools.rubygems.install
        name: 'execjs'
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.true()

  they 'remove a non existing package', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
    , ->
      await @tools.rubygems.install
        name: 'execjs'
      await @tools.rubygems.remove
        name: 'execjs'
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.false()

  they 'remove multiple versions', ({ssh}) ->
    nikita
      $ssh: ssh
      ruby: test.ruby
    , ->
      await @tools.rubygems.install
        name: 'execjs'
        version: '2.6.0'
      await @tools.rubygems.install
        name: 'execjs'
        version: '2.7.0'
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.true()
      {$status} = await @tools.rubygems.remove
        name: 'execjs'
      $status.should.be.false()
