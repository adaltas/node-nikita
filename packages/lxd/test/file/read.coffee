
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.file.read', ->
  return unless test.tags.lxd

  they 'file with content', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-read-1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-read-1'
        start: true
      await @lxc.exec
        command: "echo 'ok' > /root/a_file"
        container: 'nikita-file-read-1'
      {data} = await @lxc.file.read
        container: 'nikita-file-read-1'
        target: '/root/a_file'
      data.should.eql 'ok\n'
      await @clean()

  they.skip 'empty file', ({ssh}) ->
    # See https://github.com/lxc/lxd/issues/11388
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-read-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-read-2'
        start: true
      await @lxc.exec
        command: "touch /root/a_file"
        container: 'nikita-file-read-2'
      {data} = await @lxc.file.read
        container: 'nikita-file-read-2'
        target: '/root/a_file'
      data.should.eql ''
      await @clean()

  they 'option `trim`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-read-3', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-file-read-3'
        start: true
      await @lxc.exec
        command: "echo 'ok' > /root/a_file"
        container: 'nikita-file-read-3'
      {data} = await @lxc.file.read
        container: 'nikita-file-read-3'
        target: '/root/a_file'
        trim: true
      data.should.eql 'ok'
      await @clean()
