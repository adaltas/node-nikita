
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.types.wireguard_conf', ->

  they 'simple values', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.wireguard_conf
      target: "#{scratch}/wireguard.conf"
      content:
        'Interface':
          'Address': '10.10.11.1/24'
          'ListenPort': '51820'
          'PrivateKey': 'XXX/XXX+XXX='
        'Peer':
          'PublicKey': 'XXX='
          'AllowedIPs': '10.10.11.0/24'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/wireguard.conf"
      content: """
      [Interface]
      Address = 10.10.11.1/24
      ListenPort = 51820
      PrivateKey = XXX/XXX+XXX=
      [Peer]
      PublicKey = XXX=
      AllowedIPs = 10.10.11.0/24
      
      """
    .promise()

  they 'multiple values', ({ssh}) ->
    p = nikita
      ssh: ssh
    .file.types.wireguard_conf
      target: "#{scratch}/wireguard.conf"
      content:
        'Interface':
          'Address': [
            '10.10.11.1/24'
            'fd86:ea04:1111::1/64'
          ]
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/wireguard.conf"
      content: """
      [Interface]
      Address = 10.10.11.1/24
      Address = fd86:ea04:1111::1/64
      
      """
    .promise()
