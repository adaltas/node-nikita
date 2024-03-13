
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.list', ->
  return unless test.tags.incus

  they 'list all instances', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @incus.delete 'nikita-list-c1', force: true
        await @incus.delete 'nikita-list-vm1', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-list-c1'
      await @incus.init
        $if: test.tags.incus_vm
        image: "images:#{test.images.alpine}"
        container: 'nikita-list-vm1'
        vm: true
      await @wait time: 200
      {$status, list} = await @incus.list()
      $status.should.be.true()
      list.should.containEql 'nikita-list-c1'
      list.should.containEql 'nikita-list-vm1' if test.tags.incus_vm
      await @clean()

  describe 'option `filter`', ->
  
    they 'when `containers`, only display containers', ({ssh}) ->
      nikita
        $ssh: ssh
    , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-list-c1', force: true
          @incus.delete 'nikita-list-vm1', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-c1'
        await @incus.init
          $if: test.tags.incus_vm
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-vm1'
          vm: true
        {$status, list} = await @incus.list
          filter: 'containers'
        $status.should.be.true()
        list.should.containEql 'nikita-list-c1'
        list.should.not.containEql 'nikita-list-vm1' if test.tags.incus_vm
        await @clean()

    they 'when `virtual-machines`, only display VMs', ({ssh}) ->
      nikita
        $ssh: ssh
    , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-list-c1', force: true
          @incus.delete 'nikita-list-vm1', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-c1'
        await @incus.init
          $if: test.tags.incus_vm
          image: "images:#{test.images.alpine}"
          container: 'nikita-list-vm1'
          vm: true
        {$status, list} = await @incus.list
          filter: 'virtual-machines'
        $status.should.be.true()
        list.should.not.containEql 'nikita-list-c1'
        list.should.containEql 'nikita-list-vm1' if test.tags.incus_vm
        await @clean()
