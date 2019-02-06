nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxc} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxc_start

describe 'lxc.start' ->

  they 'Start a container', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.delete
      name: 'u1'
      force: true
    .lxc.init
      image: 'ubuntu:16.04'
      name: 'u1'
    .lxc.start
      name: 'u1'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Already started', (ssh) ->
    nikita
      ssh: ssh
      lxc: lxc
    .lxc.delete
      name: 'u1'
    .lxc.init
      image: 'ubuntu:16.04'
      name: 'u1'
    .lxc.start
      name: 'u1'
    .lxc.start
      name: 'u1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
