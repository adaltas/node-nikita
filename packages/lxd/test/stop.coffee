
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.stop', ->

  they 'Stop a container', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.delete
      name: 'u1'
      force: true
    .lxd.init
      image: 'ubuntu:16.04'
      name: 'u1'
    .lxd.start
      name: 'u1'
    .lxd.stop
      name: 'u1'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Already stopped', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.delete
      name: 'u1'
      force: true
    .lxd.init
      image: 'ubuntu:16.04'
      name: 'u1'
    .lxd.stop
      name: 'u1'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
