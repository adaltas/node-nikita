
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd
  
before () ->
  nikita
  .system.execute
    cmd: "lxc image copy ubuntu:default `lxc remote get-default`:"
  .promise()

describe 'lxd.exec', ->

  they 'a command with pipe inside', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'container1'
      force: true
    .lxd.init
      image: 'ubuntu:'
      container: 'container1'
    .lxd.start
      container: 'container1'
    .lxd.exec
      container: 'container1'
      cmd: """
      cat /etc/lsb-release | grep DISTRIB_ID
      """
    , (err, {status, stdout}) ->
      stdout.trim().should.eql 'DISTRIB_ID=Ubuntu'
    .promise()

  describe 'option trap', ->

    they 'is enabled', ({ssh}) ->
      nikita
        ssh: ssh
      .lxd.delete
        container: 'container1'
        force: true
      .lxd.init
        image: 'ubuntu:'
        container: 'container1'
      .lxd.start
        container: 'container1'
      .lxd.exec
        container: 'container1'
        relax: true
        trap: true
        cmd: """
        false
        true
        """
      , (err) ->
        err.code.should.eql 1
      .promise()

    they 'is disabled', ({ssh}) ->
      nikita
        ssh: ssh
      .lxd.delete
        container: 'container1'
        force: true
      .lxd.init
        image: 'ubuntu:'
        container: 'container1'
      .lxd.start
        container: 'container1'
      .lxd.exec
        container: 'container1'
        trap: false
        cmd: """
        false
        true
        """
      , (err, {status, code}) ->
        code.should.eql 0
      .promise()
