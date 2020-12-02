
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.state', ->
      
  they 'Show instance state', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: 'ubuntu:'
        container: 'u1'
      {status, config} = await @lxd.state
        container: 'u1'
      status.should.be.true()
      config.status.should.eql 'Stopped'

  they 'Instance not found', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      @lxd.state
        container: 'u1'
      .should.be.rejectedWith
        exit_code: 1
