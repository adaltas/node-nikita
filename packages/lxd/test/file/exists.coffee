
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

describe 'lxd.file.exists', ->

  they 'when present', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.start
      container: 'c1'
    .system.execute
      cmd: "lxc exec c1 -- touch /root/a_file"
    .lxd.file.exists
      container: 'c1'
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'when missing', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.start
      container: 'c1'
    .lxd.file.exists
      container: 'c1'
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
