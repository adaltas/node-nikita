
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'file.types.systemd.resolved', ->

  they 'servers as a string', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.systemd.resolved
      target: "#{scratch}/resolved.conf"
      content:
        FallbackDNS: "1.1.1.1"
      reload: false
    .file.assert
      target: "#{scratch}/resolved.conf"
      content: """
      [Resolve]
      FallbackDNS=1.1.1.1
      """
      trim: true
    .promise()

  they 'servers as an array', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.systemd.resolved
      target: "#{scratch}/resolved.conf"
      content:
        FallbackDNS: ["1.1.1.1", "9.9.9.10", "8.8.8.8", "2606:4700:4700::1111"]
      reload: false
    .file.assert
      target: "#{scratch}/resolved.conf"
      content: """
      [Resolve]
      FallbackDNS=1.1.1.1 9.9.9.10 8.8.8.8 2606:4700:4700::1111
      """
      trim: true
    .promise()

  they 'merge values', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.systemd.resolved
      target: "#{scratch}/resolved.conf"
      content:
        DNS: "ns0.fdn.fr"
      reload: false
    .file.assert
      target: "#{scratch}/resolved.conf"
      content: """
      [Resolve]
      DNS=ns0.fdn.fr
      """
      trim: true
    .file.types.systemd.resolved
      target: "#{scratch}/resolved.conf"
      content:
        ReadEtcHosts: "true"
      merge: true
      reload: false
    .file.assert
      target: "#{scratch}/resolved.conf"
      content: """
      [Resolve]
      DNS=ns0.fdn.fr
      ReadEtcHosts=true
      """
      trim: true
    .promise()

