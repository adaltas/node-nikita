
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.file.read', ->
  return unless test.tags.incus

  they 'file with content', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-file-read-1', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-read-1'
        start: true
      await @incus.exec
        command: "echo 'ok' > /root/a_file"
        container: 'nikita-file-read-1'
      {data} = await @incus.file.read
        container: 'nikita-file-read-1'
        target: '/root/a_file'
      data.should.eql 'ok\n'
      await @clean()

  they.skip 'empty file', ({ssh}) ->
    # See https://github.com/incus/incus/issues/11388
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-file-read-2', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-read-2'
        start: true
      await @incus.exec
        command: "touch /root/a_file"
        container: 'nikita-file-read-2'
      {data} = await @incus.file.read
        container: 'nikita-file-read-2'
        target: '/root/a_file'
      data.should.eql ''
      await @clean()

  they 'option `trim`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-file-read-3', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-read-3'
        start: true
      await @incus.exec
        command: "echo 'ok' > /root/a_file"
        container: 'nikita-file-read-3'
      {data} = await @incus.file.read
        container: 'nikita-file-read-3'
        target: '/root/a_file'
        trim: true
      data.should.eql 'ok'
      await @clean()
