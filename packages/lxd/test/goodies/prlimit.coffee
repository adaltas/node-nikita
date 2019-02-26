
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd_prlimit

describe 'lxd.goodie.prlimit', ->

  they 'stdout', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      name: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      name: 'c1'
    .lxd.start
      name: 'c1'
    .lxd.goodies.prlimit
      name: 'c1'
    .promise()
