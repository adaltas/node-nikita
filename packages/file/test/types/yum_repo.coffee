
import nikita from '@nikitajs/core'
import utils from '@nikitajs/file/utils'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.types.yum_repo', ->
  return unless test.tags.posix

  they 'generate from content object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.1":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.true()
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.1":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.false()
      await @fs.assert
        target: "#{tmpdir}/test.repo"

  they 'merge with content object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.2":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.true()
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          "test-repo-0.0.2":
            'gpgcheck': '0'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
        merge: true
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/test.repo"

  they 'write to default repository dir', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.yum_repo
        target: "#{tmpdir}/test.repo"
        content:
          'test-repo-0.0.3':
            'name': 'CentOS'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org'
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/test.repo"
        content: """
          [test-repo-0.0.3]
          name = CentOS
          mirrorlist = http://test/?infra=$infra
          baseurl = http://mirror.centos.org\n
        """
        trim: true

  they 'default from source with content', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.types.yum_repo
        target: "#{tmpdir}/original.repo"
        content:
          'test-repo-0.0.3':
            'name': 'CentOS'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org'
      {$status} = await @file.types.yum_repo
        local: true
        source: "#{tmpdir}/original.repo"
        target: "#{tmpdir}/new.repo"
        content:
          "test-repo-0.0.4":
            'name': 'CentOS-$releasever - Base'
            'mirrorlist': 'http://test/?infra=$infra'
            'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck': '1'
            'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/new.repo"
      {data} = await @file.ini.read
        parse: utils.ini.parse_multi_brackets,
        target: "#{tmpdir}/new.repo"
      Object.keys(data).should.eql [ 'test-repo-0.0.3', 'test-repo-0.0.4' ]
