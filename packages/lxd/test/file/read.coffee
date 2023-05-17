
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.file.read', ->

  they 'file with content', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-read-1', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
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
        image: "images:#{images.alpine}"
        container: 'nikita-file-read-2'
        start: true
      await @lxc.exec
        command: "touch /root/a_file"
        container: 'nikita-file-read-2'
      {data} = await @lxc.file.read
        $debug: true
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
        image: "images:#{images.alpine}"
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
