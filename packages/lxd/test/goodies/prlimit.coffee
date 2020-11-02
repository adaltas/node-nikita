
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd_prlimit

before () ->
  await nikita
  .execute
    cmd: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.goodie.prlimit', ->

  they 'stdout', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.start
        container: 'c1'
      await @lxd.goodies.prlimit
        container: 'c1'
