
nikita = require '@nikitajs/engine/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

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
