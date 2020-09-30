
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd_prlimit

describe 'lxd.goodie.prlimit', ->

  they 'stdout', ({ssh}) ->
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
    .lxd.goodies.prlimit
      container: 'c1'
    .promise()
