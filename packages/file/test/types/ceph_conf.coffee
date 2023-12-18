
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.types.ceph_conf', ->
  return unless test.tags.posix

  they 'generate from content', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.ceph_conf
        target: "#{tmpdir}/ceph_conf_test.repo"
        content:
          'global':
            'fsid': 'a7-a6-d0'
            'prop with spaces': '2spaces'
            'prop ip': '192.168.10.1'
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/ceph_conf_test.repo"
        content: "[global]\nfsid = a7-a6-d0\nprop with spaces = 2spaces\nprop ip = 192.168.10.1\n"

  they 'status not modified', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.ceph_conf
        target: "#{tmpdir}/ceph_conf_test.repo"
        content:
          'global':
            'fsid': 'a7-a6-d0'
            'prop with spaces': '2spaces'
            'prop ip': '192.168.10.1'
      $status.should.be.true()
      {$status} = await @file.types.ceph_conf
        target: "#{tmpdir}/ceph_conf_test.repo"
        content:
          'global':
            'fsid': 'a7-a6-d0'
            'prop with spaces': '2spaces'
            'prop ip': '192.168.10.1'
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/ceph_conf_test.repo"
        content: "[global]\nfsid = a7-a6-d0\nprop with spaces = 2spaces\nprop ip = 192.168.10.1\n"
