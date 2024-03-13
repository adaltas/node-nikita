
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage.exists', ->
  return unless test.tags.incus

  they 'argument is a string', ({ssh}) ->
    await nikita.incus.storage.exists 'nikita-storage-exists-1', ({config}) ->
      config.name.should.eql 'nikita-storage-exists-1'

  they 'with existing storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.storage
        name: 'nikita-storage-exists-2'
        driver: "zfs"
      {exists} = await @incus.storage.exists 'nikita-storage-exists-2'
      exists.should.be.true()
      await @incus.storage.delete 'nikita-storage-exists-2'

  they 'with missing storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {exists} = await @incus.storage.exists 'nikita-storage-exists-3'
      exists.should.be.false()
      
