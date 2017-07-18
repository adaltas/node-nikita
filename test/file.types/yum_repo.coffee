
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.types.yum_repo', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_yum_conf

  they 'generate from content object', (ssh) ->
    nikita
      ssh: ssh
    .file.types.yum_repo
      target: "#{scratch}/test.repo"
      content:
        "test-repo-0.0.1":
          'name': 'CentOS-$releasever - Base'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck': '1'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
    , (err, status) ->
      status.should.be.true() unless err
    .file.types.yum_repo
      target: "#{scratch}/test.repo"
      content:
        "test-repo-0.0.1":
          'name': 'CentOS-$releasever - Base'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck': '1'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/test.repo"
    .promise()

  they 'merge with content object', (ssh) ->
    nikita
      ssh: ssh
    .file.types.yum_repo
      target: "#{scratch}/test.repo"
      content:
        "test-repo-0.0.2":
          'name': 'CentOS-$releasever - Base'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck': '1'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
    , (err, status) ->
      status.should.be.true() unless err
    .file.types.yum_repo
      target: "#{scratch}/test.repo"
      content:
        "test-repo-0.0.2":
          'gpgcheck': '0'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.repo"
    .promise()

  they 'write to default repository dir', (ssh) ->
    nikita
    .file.types.yum_repo
      target: "#{scratch}/test.repo"
      content:
        "test-repo-0.0.3":
          'name': 'CentOS'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.repo"
      content: """
        [test-repo-0.0.3]\nname = CentOS\nmirrorlist = http://test/?infra=$infra\nbaseurl = http://mirror.centos.org\n
      """
    .promise()

  they 'default from source with content', (ssh) ->
    nikita
      ssh: ssh
    .file.types.yum_repo
      target: "#{scratch}/CentOS-nikita.repo"
      source: "#{__dirname}/../resources/CentOS-nikita.repo"
      local: true
      content:
        "test-repo-0.0.4":
          'name': 'CentOS-$releasever - Base'
          'mirrorlist': 'http://test/?infra=$infra'
          'baseurl': 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck': '1'
          'gpgkey': 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/CentOS-nikita.repo"
    .promise()
