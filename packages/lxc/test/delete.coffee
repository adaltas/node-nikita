
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxc} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxc_delete

describe 'lxc.delete' ->

  they 'Delete a container', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.init
      image: 'ubuntu:'
      name: 'delme'
    .lxc.delete
      name: 'delme'
    , (err, {status}) ->
      status.should.be.true()
    .promise()


  they 'Force deletion of a running container', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.init
      image: 'ubuntu:'
      name: 'delme'
    .lxc.start
      name: 'delme'
    .delete
      name: 'delme'
      force: true
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Not found', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.init
      image: 'ubuntu:'
      name: 'delme'
    .lxc.delete
      name: 'delme'
    .lxc.delete
      name: 'delme'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
