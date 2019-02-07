nikita = require '@nikitajs/core'
{tags, ssh} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxd

describe 'lxd.network', ->

  describe 'Network creation', ->
    
    they 'Network creation with options', (ssh) ->
      nikita
        ssh: ssh
      .lxd.network.delete
        name: 'lxdnetwork0test'
      .lxd.network
        name: 'lxdnetwork0test'
        config:
          ipv4:
            adress: "174.89.0.0/24"
            nat: true
          ipv6:
            address: null
      , (err, {status}) ->
        status.should.be.true()
      .promise()

    they 'Network already exist', (ssh) ->
      nikita
        ssh: ssh
      .lxd.network.delete
        name: 'lxdnetwork0test'
      .lxd.network
        name: 'lxdnetwork0test'
      .lxd.network
        name: 'lxdnetwork0test'
      , (err, {status}) ->
        status.should.be.false()
      .promise()

  describe 'Network deletion', ->
    
    they 'Delete a network', (ssh) ->
      nikita
        ssh: ssh
      .lxd.network
        name: 'lxdnetwork0test'
      .lxd.network.delete
        name: 'lxdnetwork0test'
      , (err, {status}) ->
        status.should.be.true()
      .promise()

    they 'Network does not exist', (ssh) ->
      nikita
        ssh: ssh
      .lxd.network
        name: 'lxdnetwork0test'
      .lxd.network.delete
        name: 'lxdnetwork0test'
      .lxd.network.delete
        name: 'lxdnetwork0test'
      , (err, {status}) ->
        status.should.be.false()
      .promise()

    they 'Configure Network', (ssh) ->
      nikita
        ssh: ssh
      .lxd.network
        name: 'lxdnetwork0test'
      .lxd.network.configure
        name: 'lxdnetwork0test'
        config:
          ipv4:
            address: '172.18.0.1/24'
          ipv6:
            address: null
      , (err, {status, config}) ->
        status.should.be.true()
        config.should.be.eql(
          ipv4:
            address: '172.18.0.1/24'
          ipv6:
            address: null
        )
      .promise()

  describe 'Attach network', ->

    they 'Attach to a container', (ssh) ->
      nikita
        ssh: ssh
      .lxd.init
        image: 'ubuntu:16.04'
        name: 'u1'
      .lxd.network
        name: 'lxdnetwork0test'
      .lxd.network.attach
        network: 'lxdnetwork0test'
        container: 'u1'
      , (err, {status}) ->
        status.should.be.true()
      .promise()

    # they 'Attach to a profile'

  describe 'Detach network', ->

    they 'Detach from a container', (ssh) ->
      nikita
        ssh: ssh
      .lxd.init
        image: 'ubuntu:16.04'
        name: 'u1'
      .lxd.network
        name: 'lxdnetwork0test'
      .lxd.network.attach
        network: 'lxdnetwork0test'
        container: 'u1'
      .lxd.network.detach
        network: 'lxdnetwork0test'
        container: 'u1'
      , (err, {status}) ->
        status.should.be.true()
      .promise()
    # they 'Detach from a profile'
