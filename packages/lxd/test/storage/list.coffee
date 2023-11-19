
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.storage.list', ->
  return unless test.tags.lxd

  they 'List storages', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: 'nikita-storage-list-1'
        driver: 'zfs'
      {storages} = await @lxc.storage.list()
      storage = storages.find (storage) -> storage.name is 'nikita-storage-list-1'
      storage.should.match
        config: {
          size: /\d+\w+/ # eg "19GiB"
          source: (source) => source.endsWith 'nikita-storage-list-1.img'
          'zfs.pool_name': 'nikita-storage-list-1'
        },
        description: ''
        driver: 'zfs'
        locations: [ 'none' ]
        name: 'nikita-storage-list-1'
        status: 'Created'
        used_by: null
      await @lxc.storage.delete 'nikita-storage-list-1'
      
