
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'
fs = require 'ssh2-fs'

describe 'tools.repo', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_tools_repo
  @timeout 50000

  they 'Write with source option', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove "#{scratch}/repo/centos.repo"
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
    .then next
  
  they 'Write with content option', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove "#{scratch}/repo/centos.repo"
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
    .then next
  
  they 'delete files with replace option', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove '/etc/yum.repos.d/CentOS-nikita.repo'
    .file.touch '/etc/yum.repos.d/test.repo'
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
      replace: 'test*'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      source: "#{scratch}/CentOS.repo"
      replace: 'test*'
    , (err, status) ->
      status.should.be.false() unless err
    .tools.repo
      source: "#{scratch}/CentOS.repo"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert '/etc/yum.repos.d/CentOS.repo'
    .system.remove '/etc/yum.repos.d/CentOS.repo'
    .then next
  
  they 'Download GPG Keys option', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove "#{scratch}/hdp-test.repo"
    .system.remove '/etc/yum.repos.d/hdp-test.repo'
    .system.remove '/etc/pki/rpm-gpg/RPM-GPG-KEY-Jenkins'
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
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      source: "#{scratch}/hdp-test.repo"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert '/etc/yum.repos.d/hdp-test.repo'
    .system.remove '/etc/yum.repos.d/hdp-test.repo'
    .system.remove '/etc/pki/rpm-gpg/RPM-GPG-KEY-Jenkins'
    .then next
  
  they 'Download repo from remote location', (ssh, next) ->
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
    .then next

  they 'Do Not update Package', (ssh, next) ->
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
    .then next

  they 'Update Package', (ssh, next) ->
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
    .then next
