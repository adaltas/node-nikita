
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  await nikita
  .execute
    cmd: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.start', ->

  they 'Start a container', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: 'ubuntu:'
        container: 'u1'
      {status} = await @lxd.start
        container: 'u1'
      status.should.be.true()

  they 'Already started', ({ssh}) ->
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
      {status} = await @lxd.start
        container: 'u1'
      status.should.be.false()
