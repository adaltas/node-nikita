
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage.list', ->
  return unless test.tags.incus

  they 'List storages', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.storage
        name: 'nikita-storage-list-1'
        driver: 'zfs'
      {storages} = await @incus.storage.list()
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
        used_by: []
      await @incus.storage.delete 'nikita-storage-list-1'
      
