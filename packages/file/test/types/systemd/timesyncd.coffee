
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.types.systemd.timesyncd', ->
  return unless test.tags.posix

  they 'servers as a string', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.types.systemd.timesyncd
        target: "#{tmpdir}/timesyncd.conf"
        content:
          NTP: 'ntp.domain.com'
          FallbackNTP: 'fallback.domain.com'
        reload: false
      await @fs.assert
        target: "#{tmpdir}/timesyncd.conf"
        content: """
        [Time]
        NTP=ntp.domain.com
        FallbackNTP=fallback.domain.com
        """
        trim: true

  they 'servers as an array', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.types.systemd.timesyncd
        target: "#{tmpdir}/timesyncd.conf"
        content:
          NTP: ['ntp.domain.com', 'ntp.domain2.com', 'ntp.domain3.com']
          FallbackNTP: ['fallback.domain.com', 'fallback.domain2.com', 'fallback.domain3.com']
        reload: false
      await @fs.assert
        target: "#{tmpdir}/timesyncd.conf"
        content: """
        [Time]
        NTP=ntp.domain.com ntp.domain2.com ntp.domain3.com
        FallbackNTP=fallback.domain.com fallback.domain2.com fallback.domain3.com
        """
        trim: true

  they 'option `merge`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.types.systemd.timesyncd
        target: "#{tmpdir}/timesyncd.conf"
        content:
          RootDistanceMaxSec: 5
        reload: false
      await @fs.assert
        target: "#{tmpdir}/timesyncd.conf"
        content: """
        [Time]
        RootDistanceMaxSec=5
        """
        trim: true
      await @file.types.systemd.timesyncd
        target: "#{tmpdir}/timesyncd.conf"
        content:
          PollIntervalMinSec: 32
        merge: true
        reload: false
      await @fs.assert
        target: "#{tmpdir}/timesyncd.conf"
        content: """
        [Time]
        RootDistanceMaxSec=5
        PollIntervalMinSec=32
        """
        trim: true
