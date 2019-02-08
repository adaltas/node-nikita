
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxd

describe 'lxd.network.create', ->
  they 'Create a new network', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.network.delete
      name: 'net0'
    .lxd.network
      name: 'net0'
      config:
        "ipv4.address": "178.16.0.1/24"
    , (err, {status}) ->
      status.should.be.true()
    .promise()


  they 'Update a network', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.network.delete
      name: 'net0'
    .lxd.network
      name: 'net0'
      config:
        "ipv4.address": "178.16.0.1/24"
    .lxd.network
      name: 'net0'
      config:
        "ipv4.address": "179.16.0.1/24"
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Configuration unchanged', (ssh) ->
    nikita
      ssh: ssh
      lxd: lxd
    .lxd.network.delete
      name: 'net0'
    .lxd.network
      name: 'net0'
      config:
        "ipv4.address": "178.16.0.1/24"
    .lxd.network
      name: 'net0'
      config:
        "ipv4.address": "178.16.0.1/24"
    , (err, {status}) ->
      status.should.be.false()
    .promise()
