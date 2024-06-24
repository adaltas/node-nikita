
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.sysctl.file.read', ->
  return unless test.tags.posix

  they 'Read a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # Disable swap
        vm.swappiness = 10
        # Disable IPv6
        net.ipv6.conf.all.disable_ipv6=1
        """
      await @tools.sysctl.file.read
        target: "#{tmpdir}/sysctl.conf"
      .then ({$status, data}) =>
        $status.should.be.false
        data.should.eql
          'vm.swappiness': '10'
          'net.ipv6.conf.all.disable_ipv6': '1'

  they 'Config `comment`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # Disable swap
        vm.swappiness = 10
        # Disable IPv6
        net.ipv6.conf.all.disable_ipv6=1
        """
      await @tools.sysctl.file.read
        target: "#{tmpdir}/sysctl.conf"
        comment: true
      .then ({$status, data}) =>
        $status.should.be.false
        data.should.eql
          '# Disable swap': null
          'vm.swappiness': '10'
          '# Disable IPv6': null
          'net.ipv6.conf.all.disable_ipv6': '1'
