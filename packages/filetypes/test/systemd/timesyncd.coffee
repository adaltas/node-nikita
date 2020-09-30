
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'file.types.systemd.timesyncd', ->

  they 'servers as a string', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.systemd.timesyncd
      target: "#{scratch}/timesyncd.conf"
      content:
        NTP: 'ntp.domain.com'
        FallbackNTP: 'fallback.domain.com'
      reload: false
    .file.assert
      target: "#{scratch}/timesyncd.conf"
      content: """
      [Time]
      NTP=ntp.domain.com
      FallbackNTP=fallback.domain.com
      """
      trim: true
    .promise()

  they 'servers as an array', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.systemd.timesyncd
      target: "#{scratch}/timesyncd.conf"
      content:
        NTP: ['ntp.domain.com', 'ntp.domain2.com', 'ntp.domain3.com']
        FallbackNTP: ['fallback.domain.com', 'fallback.domain2.com', 'fallback.domain3.com']
      reload: false
    .file.assert
      target: "#{scratch}/timesyncd.conf"
      content: """
      [Time]
      NTP=ntp.domain.com ntp.domain2.com ntp.domain3.com
      FallbackNTP=fallback.domain.com fallback.domain2.com fallback.domain3.com 
      """
      trim: true
    .promise()

  they 'merge values', ({ssh}) ->
    nikita
      ssh: ssh
    .file.types.systemd.timesyncd
      target: "#{scratch}/timesyncd.conf"
      content:
        RootDistanceMaxSec: 5
      reload: false
    .file.assert
      target: "#{scratch}/timesyncd.conf"
      content: """
      [Time]
      RootDistanceMaxSec=5
      """
      trim: true
    .file.types.systemd.timesyncd
      target: "#{scratch}/timesyncd.conf"
      content:
        PollIntervalMinSec: 32
      merge: true
      reload: false
    .file.assert
      target: "#{scratch}/timesyncd.conf"
      content: """
      [Time]
      RootDistanceMaxSec=5
      PollIntervalMinSec=32
      """
      trim: true
    .promise()

