
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.exec', ->

  they 'a command with pipe inside', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.delete
      name: 'container1'
      force: true
    .lxd.init
      image: 'ubuntu:16.04'
      name: 'container1'
    .lxd.start
      name: 'container1'
    .lxd.exec
      name: 'container1'
      cmd: """
      cat /etc/lsb-release | grep DISTRIB_ID
      """
    , (err, {status, stdout}) ->
      stdout.trim().should.eql 'DISTRIB_ID=Ubuntu'
    .promise()
