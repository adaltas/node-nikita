
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
      name: 'container1'
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
      name: 'container1'
    .lxc.start
      name: 'container1'
    .delete
      name: 'container1'
      force: true
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Not found', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    lxc.delete  # repeated to be sure the container is absent
      name: 'container1'
    .lxc.delete
      name: 'container1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
