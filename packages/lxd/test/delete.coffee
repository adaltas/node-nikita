
nikita = require '@nikitajs/engine/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.delete', ->

  they 'Delete a container', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      await @lxd.stop
        container: 'c1'
      {status} = await @lxd.delete
        container: 'c1'
      status.should.be.true()
      {status} = await @lxd.delete
        container: 'c1'
      status.should.be.false()
  
  they 'Force deletion of a running container', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      await @lxd.start
        container: 'c1'
      {status} = await @lxd.delete
        container: 'c1'
        force: true
      status.should.be.true()

  they 'Not found', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete  # repeated to be sure the container is absent
        container: 'c1'
      {status} = await @lxd.delete
        container: 'c1'
      status.should.be.false()
