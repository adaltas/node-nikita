
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
      await @incus.list()
        .then ({$status, instances}) =>
          instances = instances.map (instance) => instance.name
          $status.should.be.true()
          instances.should.containEql 'nikita-list-c1'
          instances.should.containEql 'nikita-list-vm1' if test.tags.incus_vm
      await @clean()

  describe 'option `type`', ->

    they 'filter containers', ({ssh}) ->
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
        {$status, instances} = await @incus.list
          type: 'container'
        $status.should.be.true()
        instances = instances.map (instance) => instance.name
        instances.should.containEql 'nikita-list-c1'
        instances.should.not.containEql 'nikita-list-vm1' if test.tags.incus_vm
        await @clean()

    they 'filter virtual-machines', ({ssh}) ->
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
        {$status, instances} = await @incus.list
          type: 'virtual-machine'
        $status.should.be.true()
        instances = instances.map (instance) => instance.name
        instances.should.not.containEql 'nikita-list-c1'
        instances.should.containEql 'nikita-list-vm1' if test.tags.incus_vm
        await @clean()
