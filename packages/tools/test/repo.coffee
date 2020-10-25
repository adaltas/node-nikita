
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.tools_repo

describe 'tools.repo', ->

  @timeout 200000

  they 'Write with source option', ({ssh}) ->
    nikita
      ssh: ssh
    .system.mkdir "#{tmpdir}/repo"
    .file
      target: "#{tmpdir}/CentOS.repo"
      content: """
      [base]
      name=CentOS-$releasever - Base
      mirrorlist=http://localhost?release=$releasever&arch=$basearch&repo=os&infra=$infra
      baseurl=http://localhost/centos/$releasever/os/$basearch/
      gpgcheck=1
      gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
      """
    .tools.repo
      source: "#{tmpdir}/CentOS.repo"
      target: "#{tmpdir}/repo/centos.repo"
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.repo
      source: "#{tmpdir}/CentOS.repo"
      target: "#{tmpdir}/repo/centos.repo"
    , (err, {status}) ->
      status.should.be.false() unless err
    .fs.assert "#{tmpdir}/repo/centos.repo"
  
  they 'Write with content option', ({ssh}) ->
    nikita
      ssh: ssh
    .system.mkdir "#{tmpdir}/repo"
    .tools.repo
      target: "#{tmpdir}/repo/centos.repo"
      content:
        'base':
          'name':'CentOS-$releasever - Base'
          'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck':'0'
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.repo
      target: "#{tmpdir}/repo/centos.repo"
      content:
        'base':
          'name':'CentOS-$releasever - Base'
          'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
          'gpgcheck':'0'
    , (err, {status}) ->
      status.should.be.false() unless err
    .fs.assert
      target: "#{tmpdir}/repo/centos.repo"
      content: '[base]\nname = CentOS-$releasever - Base\nbaseurl = http://mirror.centos.org/centos/$releasever/os/$basearch/\ngpgcheck = 0\n'
  
  they 'delete files with replace option', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{tmpdir}/CentOS.repo"
      content: """
        [base]
        name=CentOS-$releasever - Base
        mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
        baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
        gpgcheck=1
        gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
      """
    .tools.repo
      source: "#{tmpdir}/CentOS.repo"
      clean: 'test*'
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.touch
      target: "#{tmpdir}/test.repo"
    .tools.repo
      source: "#{tmpdir}/CentOS.repo"
      clean: "#{tmpdir}/test*"
    , (err, {status}) ->
      status.should.be.true() unless err
    .fs.assert
      target: "#{tmpdir}/test.repo"
      not: true
  
  they 'Download GPG Keys option', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{tmpdir}/hdp-test.repo"
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
      source: "#{tmpdir}/hdp-test.repo"
      gpg_dir: "#{tmpdir}"
      update: false
    .fs.assert "#{tmpdir}/RPM-GPG-KEY-Jenkins"
  
  they 'Download repo from remote location', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.remove '/etc/yum.repos.d/hdp.repo'
    .tools.repo
      source: "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/hdp.repo"
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.repo
      source: "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/hdp.repo"
    , (err, {status}) ->
      status.should.be.false() unless err
    .fs.assert '/etc/yum.repos.d/hdp.repo'

  they 'Do Not update Package', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.remove '/etc/yum.repos.d/mongodb.repo'
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
    , (err, {status}) ->
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
    , (err, {status}) ->
      status.should.be.false() unless err
    .service.install
      name: 'mongodb-org-shell'
    .execute
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
    , (err, {status}) ->
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
    , (err, {status}) ->
      status.should.be.false() unless err
    .execute
      cmd: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"

  they 'Update Package', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.remove '/etc/yum.repos.d/mongodb.repo'
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
    .execute
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
    , (err, {status}) ->
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
    , (err, {status}) ->
      status.should.be.false() unless err
    .execute
      cmd: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.4'"
