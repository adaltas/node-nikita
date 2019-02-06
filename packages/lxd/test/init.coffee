
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxc} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxc_init

describe 'lxc.init' ->

  they 'Init new container', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.delete
      name: 'u1'
    .lxc.init
      image: 'ubuntu:16.04'
      name: 'u1'
      network: 'net1'
      storage: 'pool1'
      profile: 'profile1'
      ephemeral: false
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Container already exist', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.delete
      name: 'u1'
    .lxc.init
      image: 'ubuntu:16.04'
      name: 'u1'
    .lxc.init
      image: 'ubuntu:18.04'
      name: 'u1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
