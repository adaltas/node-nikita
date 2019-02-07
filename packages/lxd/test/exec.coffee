
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxd_delete

describe 'lxd.exec', ->

  they 'a command with pipe inside', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.delete
      name: 'container1'
    .lxd.init
      image: 'ubuntu:'
      name: 'container1'
    .lxd.exec
      name: 'delme'
      cmd: """
      cat /etc/lsb-release | grep DISTRIB_ID
      """
    , (err, {status, stdout}) ->
      stdout.should.eql 'DISTRIB_ID=Ubuntu'
    .promise()
