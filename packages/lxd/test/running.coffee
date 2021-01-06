
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.running', ->

  they 'Running container', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: 'ubuntu:'
        container: 'u1'
      await @lxd.start
        container: 'u1'
      {status} = await @lxd.running
        container: 'u1'
      status.should.be.true()

  they 'Stopped container', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: 'ubuntu:'
        container: 'u1'
      {status} = await @lxd.running
        container: 'u1'
      status.should.be.false()
