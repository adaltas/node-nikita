
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.config.set', ->
  return unless test.tags.lxd

  they 'Set multiple keys', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.delete
        container: 'nikita-config-set-1'
        force: true
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-set-1'
      {$status} = await @lxc.config.set
        container: 'nikita-config-set-1'
        properties:
          'environment.MY_KEY_1': 'my value 1'
          'environment.MY_KEY_2': 'my value 2'
      $status.should.be.true()
      await @lxc.start
        container: 'nikita-config-set-1'
      {stdout} = await @execute
        command: "lxc exec nikita-config-set-1 -- env | grep MY_KEY_1"
        trim: true
      stdout.should.eql 'MY_KEY_1=my value 1'
      {stdout} = await @execute
        command: "lxc exec nikita-config-set-1 -- env | grep MY_KEY_2"
        trim: true
      stdout.should.eql 'MY_KEY_2=my value 2'

  they 'Does not set the same configuration', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.delete
        container: 'nikita-config-set-2'
        force: true
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-set-2'
      {$status} = await @lxc.config.set
        container: 'nikita-config-set-2'
        properties:
          'environment.MY_KEY_1': 'my value 1'
      $status.should.be.true()
      {$status} = await @lxc.config.set
        container: 'nikita-config-set-2'
        properties:
          'environment.MY_KEY_1': 'my value 1'
      $status.should.be.false()
