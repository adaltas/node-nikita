
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.file.exists', ->

  they 'when created', ({ssh}) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.init
      image: 'ubuntu:18.04'
      name: 'c1'
    .lxd.start
      name: 'c1'
    .system.execute
      cmd: "lxc exec c1 -- stat /root/a_file"
    .lxd.file.exists
      name: 'c1'
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'when missing', ({ssh}) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.init
      image: 'ubuntu:18.04'
      name: 'c1'
    .lxd.file.exists
      name: 'c1'
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
