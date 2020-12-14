
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.exec', ->

  they 'a command with pipe inside', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.delete
        container: 'c1'
        force: true
      await @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      await @lxd.start
        container: 'c1'
      {status, stdout} = await @lxd.exec
        container: 'c1'
        command: """
        cat /etc/lsb-release | grep DISTRIB_ID
        """
      stdout.trim().should.eql 'DISTRIB_ID=Ubuntu'
      status.should.be.true()

  describe 'option trap', ->

    they 'is enabled', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        await @lxd.delete
          container: 'c1'
          force: true
        await @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        await @lxd.start
          container: 'c1'
        @lxd.exec
          container: 'c1'
          trap: true
          command: """
          false
          true
          """
        .should.be.rejectedWith
          exit_code: 1

    they 'is disabled', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        await @lxd.delete
          container: 'c1'
          force: true
        await @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        await @lxd.start
          container: 'c1'
        {status, code} = await @lxd.exec
          container: 'c1'
          trap: false
          command: """
          false
          true
          """
        status.should.be.true()
        code.should.eql 0
