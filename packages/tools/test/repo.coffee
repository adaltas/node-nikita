
import path from 'node:path'
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.repo', ->
  return unless test.tags.tools_repo

  @timeout 400000

  they 'Write with source option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      # Write a local file, tools.repo will download to the remote destination
      await @file
        $ssh: false
        target: "#{tmpdir}/CentOS.repo"
        content: """
        [base]
        name=CentOS-$releasever - Base
        mirrorlist=http://localhost?release=$releasever&arch=$basearch&repo=os&infra=$infra
        baseurl=http://localhost/centos/$releasever/os/$basearch/
        gpgcheck=1
        gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        """
      await @fs.mkdir "#{tmpdir}/repo"
      {$status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        target: "#{tmpdir}/repo/centos.repo"
      $status.should.be.true()
      {$status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        target: "#{tmpdir}/repo/centos.repo"
      {$status} = await $status.should.be.false()
      await @fs.assert "#{tmpdir}/repo/centos.repo"
  
  they 'Write with content option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.mkdir "#{tmpdir}/repo"
      {$status} = await @tools.repo
        target: "#{tmpdir}/repo/centos.repo"
        content:
          'base':
            'name':'CentOS-$releasever - Base'
            'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck':'0'
      $status.should.be.true()
      {$status} = await @tools.repo
        target: "#{tmpdir}/repo/centos.repo"
        content:
          'base':
            'name':'CentOS-$releasever - Base'
            'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck':'0'
      $status.should.be.false()
      await @fs.assert
        target: "#{tmpdir}/repo/centos.repo"
        content: '[base]\nname = CentOS-$releasever - Base\nbaseurl = http://mirror.centos.org/centos/$releasever/os/$basearch/\ngpgcheck = 0\n'
  
  they 'delete files with clean option', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        $ssh: false
        target: "#{tmpdir}/source/CentOS.repo"
        content: """
          [base]
          name=CentOS-$releasever - Base
          mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
          baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
          gpgcheck=1
          gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        """
      await @tools.repo
        source: "#{tmpdir}/source/CentOS.repo"
        target: "#{tmpdir}/target/CentOS.repo"
      {$status} = await @tools.repo
        source: "#{tmpdir}/source/CentOS.repo"
        target: "#{tmpdir}/target/CentOS.repo"
        clean: 'test*'
      $status.should.be.false()
      await @file.touch
        target: "#{tmpdir}/target/test.repo"
      {$status} = await @tools.repo
        source: "#{tmpdir}/source/CentOS.repo"
        target: "#{tmpdir}/target/CentOS.repo"
        clean: "test*"
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/target/test.repo"
        not: true
  
  they 'Download GPG Keys from local source', ({ssh, sudo}) ->
    nikita
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file
        $templated: true
        target: "#{tmpdir}/chrome.repo"
        content: """
        [google-chrome]
        name=google-chrome
        baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
        skip_if_unavailable=True
        gpgcheck=1
        gpgkey=https://dl.google.com/linux/linux_signing_key.pub
        enabled=1
        """
      # Note, option `verify` is enabled by default
      # Validate status changed
      { $status } = await @tools.repo
        $sudo: sudo
        local: true
        source: "#{tmpdir}/chrome.repo"
        gpg_dir: "#{tmpdir}"
        update: false
      $status.should.be.true()
      # Validate status unchanged
      { $status } = await @tools.repo
        $sudo: sudo
        local: true
        source: "#{tmpdir}/chrome.repo"
        gpg_dir: "#{tmpdir}"
        update: false
      $status.should.be.false()
      # Ensure the GPG key is downloaded
      await @fs.assert "#{tmpdir}/linux_signing_key.pub"
  
  they 'Download repo from remote location', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @fs.remove '/etc/yum.repos.d/gh-cli.repo'
      {$status} = await @tools.repo
        source: "https://cli.github.com/packages/rpm/gh-cli.repo"
      $status.should.be.true()
      {$status} = await @tools.repo
        source: "https://cli.github.com/packages/rpm/gh-cli.repo"
      $status.should.be.false()
      await @fs.assert '/etc/yum.repos.d/gh-cli.repo'

  they 'config `update` is `false` (default)', ({ssh, sudo}) ->
    # See https://linux.die.net/man/5/yum.conf for a list of supported variables
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @fs.remove '/etc/yum.repos.d/mariadb.repo'
      await @fs.remove '/etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB'
      await @service.remove 'MariaDB-client'
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mariadb.repo'
        content:
          'mariadb':
            'name': 'MariaDB'
            'baseurl': "https://yum.mariadb.org/11.4/#{test.mariadb.distrib}-#{test.mariadb.basearch}"
            'enabled':'1'
            'module_hotfixes': '1'
            'gpgkey': 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
            'gpgcheck': '1'
      await @service.install
        name: 'MariaDB-client'
      await @execute
        command: "mariadb --version | egrep '11.4.[0-9]+-MariaDB'"
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mariadb.repo'
        content:
          'mariadb':
            'name': 'MariaDB'
            'baseurl': "https://yum.mariadb.org/11.6/#{test.mariadb.distrib}-#{test.mariadb.basearch}"
            'enabled':'1'
            'module_hotfixes': '1'
            'gpgkey': 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
            'gpgcheck': '1'
      $status.should.be.true()
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mariadb.repo'
        content:
          'mariadb':
            'name': 'MariaDB'
            'baseurl': "https://yum.mariadb.org/11.6/#{test.mariadb.distrib}-#{test.mariadb.basearch}"
            'enabled':'1'
            'module_hotfixes': '1'
            'gpgkey': 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
            'gpgcheck': '1'
      $status.should.be.false()
      await @execute
        command: "mariadb --version | egrep '11.4.[0-9]+-MariaDB'"

  they 'config `update` is `true`', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @fs.remove '/etc/yum.repos.d/mariadb.repo'
      await @fs.remove '/etc/pki/rpm-gpg/RPM-GPG-KEY-MariaDB'
      await @service.remove 'MariaDB-client'
      await @tools.repo
        target: '/etc/yum.repos.d/mariadb.repo'
        content:
          'mariadb':
            'name': 'MariaDB'
            'baseurl': "https://yum.mariadb.org/11.4/#{test.mariadb.distrib}-#{test.mariadb.basearch}"
            'enabled':'1'
            'module_hotfixes': '1'
            'gpgkey': 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
            'gpgcheck': '1'
      await @service.install
        name: 'MariaDB-client'
      await @execute
        command: "mariadb --version | egrep '11.4.[0-9]+-MariaDB'"
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mariadb.repo'
        update: true
        content:
          'mariadb':
            'name': 'MariaDB'
            'baseurl': "https://yum.mariadb.org/11.6/#{test.mariadb.distrib}-#{test.mariadb.basearch}"
            'enabled':'1'
            'module_hotfixes': '1'
            'gpgkey': 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
            'gpgcheck': '1'
      $status.should.be.true()
      {$status} = await @tools.repo
        target: '/etc/yum.repos.d/mariadb.repo'
        update: true
        content:
          'mariadb':
            'name': 'MariaDB'
            'baseurl': "https://yum.mariadb.org/11.6/#{test.mariadb.distrib}-#{test.mariadb.basearch}"
            'enabled':'1'
            'module_hotfixes': '1'
            'gpgkey': 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
            'gpgcheck': '1'
      $status.should.be.false()
      await @execute
        command: "mariadb --version | egrep '11.6.[0-9]+-MariaDB'"
  
  they 'Download config `gpg_key` fails because `gpg_key` unset and not in .repo', ({ssh, sudo}) ->
    nikita
      $ssh: ssh,
      $tmpdir: true
      $sudo: sudo
    , ({metadata: {tmpdir}}) ->
      @tools.repo
        target: "/etc/yum.repos.d/jenkins.repo"
        source: "https://pkg.jenkins.io/redhat-stable/jenkins.repo"
        gpg_dir: tmpdir
        verify: true
      .should.be.rejectedWith 'Missing gpgkey'
  
  they 'Download config `gpg_key`', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.repo
        target: "/etc/yum.repos.d/jenkins.repo"
        source: "https://pkg.jenkins.io/redhat-stable/jenkins.repo"
        gpg_key: "https://pkg.jenkins.io/redhat/jenkins.io.key"
        gpg_dir: tmpdir
        verify: true
      $status.should.be.true()
      await @fs.assert "#{tmpdir}/jenkins.io.key"
