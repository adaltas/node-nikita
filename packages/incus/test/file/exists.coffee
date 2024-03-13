
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.file.exists', ->
  return unless test.tags.incus

  they 'when present', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-file-exists-1', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-exists-1'
        start: true
      await @execute
        command: "incus exec nikita-file-exists-1 -- touch /root/a_file"
      {exists} = await @incus.file.exists
        container: 'nikita-file-exists-1'
        target: '/root/a_file'
      exists.should.be.true()
      await @clean()

  they 'when missing', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-file-exists-2', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-exists-2'
        start: true
      {exists} = await @incus.file.exists
        container: 'nikita-file-exists-2'
        target: '/root/a_file'
      exists.should.be.false()
      await @clean()

  they 'change of status', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @incus.delete 'nikita-file-exists-3', force: true
      registry.register 'test', ->
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-file-exists-3'
          start: true
        # check is exists is true
        await @incus.exec
          container: 'nikita-file-exists-3'
          command: "touch /root/a_file"
        {exists} = await @incus.file.exists
          container: 'nikita-file-exists-3'
          target: '/root/a_file'
        exists.should.be.true()
        # check is exists is false
        await @incus.exec
          container: 'nikita-file-exists-3'
          command: "rm -f /root/a_file"
        {exists} = await @incus.file.exists
          container: 'nikita-file-exists-3'
          target: '/root/a_file'
        exists.should.be.false()
      try
        await @clean()
        await @test()
      catch err
        await @clean()
      finally
        await @clean()
  
