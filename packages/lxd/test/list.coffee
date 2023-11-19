
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.list', ->
  return unless test.tags.lxd

  they 'list all instances', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-list-c1', force: true
        @lxc.delete 'nikita-list-vm1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-list-c1'
      await @lxc.init
        $if: test.tags.lxd_vm
        image: "images:#{test.images.alpine}"
        container: 'nikita-list-vm1'
        vm: true
      await @wait time: 200
      {$status, list} = await @lxc.list()
      $status.should.be.true()
      list.should.containEql 'nikita-list-c1'
      list.should.containEql 'nikita-list-vm1' if test.tags.lxd_vm
      await @clean()

  describe 'option `filter`', ->
  
    they 'when `containers`, only display containers', ({ssh}) ->
      nikita
        $ssh: ssh
    , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-list-c1', force: true
          @lxc.delete 'nikita-list-vm1', force: true
        await @clean()
        await @lxc.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-c1'
        await @lxc.init
          $if: test.tags.lxd_vm
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-vm1'
          vm: true
        {$status, list} = await @lxc.list
          filter: 'containers'
        $status.should.be.true()
        list.should.containEql 'nikita-list-c1'
        list.should.not.containEql 'nikita-list-vm1' if test.tags.lxd_vm
        await @clean()

    they 'when `virtual-machines`, only display VMs', ({ssh}) ->
      nikita
        $ssh: ssh
    , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-list-c1', force: true
          @lxc.delete 'nikita-list-vm1', force: true
        await @clean()
        await @lxc.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-c1'
        await @lxc.init
          $if: test.tags.lxd_vm
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-vm1'
          vm: true
        {$status, list} = await @lxc.list
          filter: 'virtual-machines'
        $status.should.be.true()
        list.should.not.containEql 'nikita-list-c1'
        list.should.containEql 'nikita-list-vm1' if test.tags.lxd_vm
        await @clean()
