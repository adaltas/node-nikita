
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'
fs = require 'ssh2-fs'

describe 'tools.repo', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_tools_repo
  @timeout 200000

  they 'Write with source option', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir "#{scratch}/repo"
    .file
      target: "#{scratch}/CentOS.repo"
      content: """
      [base]
      name=CentOS-$releasever - Base
      mirrorlist=http://localhost?release=$releasever&arch=$basearch&repo=os&infra=$infra
      baseurl=http://localhost/centos/$releasever/os/$basearch/
      gpgcheck=1
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
      """
    .tools.repo
      source: "#{scratch}/CentOS.repo"
      target: "#{scratch}/repo/centos.repo"
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      source: "#{scratch}/CentOS.repo"
      target: "#{scratch}/repo/centos.repo"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert "#{scratch}/repo/centos.repo"
    .promise()
  
  they 'Write with content option', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir "#{scratch}/repo"
    .tools.repo
      target: "#{scratch}/repo/centos.repo"
      content:
        'base':
          'name':'CentOS-$releasever - Base'
          'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck':'0'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      target: "#{scratch}/repo/centos.repo"
      content:
        'base':
          'name':'CentOS-$releasever - Base'
          'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck':'0'
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/repo/centos.repo"
      content: '[base]\nname = CentOS-$releasever - Base\nbaseurl = http://mirror.centos.org/centos/$releasever/os/$basearch/\ngpgcheck = 0\n'
    .promise()
  
  they 'delete files with replace option', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/CentOS.repo"
      content: """
        [base]
        name=CentOS-$releasever - Base
        mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
        baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
        gpgcheck=1
        gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
      """
    .tools.repo
      source: "#{scratch}/CentOS.repo"
      clean: 'test*'
    , (err, status) ->
      status.should.be.false() unless err
    .file.touch
      target: "#{scratch}/test.repo"
    .tools.repo
      source: "#{scratch}/CentOS.repo"
      clean: "#{scratch}/test*"
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/test.repo"
      not: true
    .promise()
  
  they 'Download GPG Keys option', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/hdp-test.repo"
      content: """
        [HDP-2.6.0.3]
        name=HDP Version - HDP-2.6.0.3
        baseurl=http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3
        gpgcheck=1
        gpgkey=http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
        enabled=1
        priority=1
      """
    .tools.repo
      source: "#{scratch}/hdp-test.repo"
      gpg_dir: "#{scratch}"
      update: false
    .file.assert "#{scratch}/RPM-GPG-KEY-Jenkins"
    .promise()
  
  they 'Download repo from remote location', (ssh) ->
    nikita
      ssh: ssh
    .system.remove '/etc/yum.repos.d/hdp.repo'
    .tools.repo
      source: "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/hdp.repo"
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      source: "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/hdp.repo"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert '/etc/yum.repos.d/hdp.repo'
    .promise()

  they 'Do Not update Package', (ssh) ->
    nikita
      ssh: ssh
    .system.remove '/etc/yum.repos.d/mongodb.repo'
    .service.remove 'mongodb-org-shell'
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      content:
        'mongodb-org-3.2':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      content:
        'mongodb-org-3.2':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
    , (err, status) ->
      status.should.be.false() unless err
    .service.install
      name: 'mongodb-org-shell'
    .system.execute
      cmd: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      content:
        'mongodb-org-3.4':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      content:
        'mongodb-org-3.4':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      , (err, status) ->
        status.should.be.false() unless err
    .system.execute
      cmd: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
    .promise()

  they 'Update Package', (ssh) ->
    nikita
      ssh: ssh
    .system.remove '/etc/yum.repos.d/mongodb.repo'
    .service.remove 'mongodb-org-shell'
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      content:
        'mongodb-org-3.2':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
    .service.install
      name: 'mongodb-org-shell'
    .system.execute
      cmd: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      update: true
      content:
        'mongodb-org-3.4':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      target: '/etc/yum.repos.d/mongodb.repo'
      update: true
      content:
        'mongodb-org-3.4':
          'name':'MongoDB Repository'
          'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
          'gpgcheck':'1'
          'enabled':'1'
          'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
    , (err, status) ->
      status.should.be.false() unless err
    .system.execute
      cmd: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.4'"
    .promise()
