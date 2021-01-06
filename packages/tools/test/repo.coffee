
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.tools_repo

describe 'tools.repo', ->

  @timeout 200000

  they 'Write with source option', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.mkdir "#{tmpdir}/repo"
      @file
        target: "#{tmpdir}/CentOS.repo"
        content: """
        [base]
        name=CentOS-$releasever - Base
        mirrorlist=http://localhost?release=$releasever&arch=$basearch&repo=os&infra=$infra
        baseurl=http://localhost/centos/$releasever/os/$basearch/
        gpgcheck=1
        gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        """
      {status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        target: "#{tmpdir}/repo/centos.repo"
      status.should.be.true()
      {status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        target: "#{tmpdir}/repo/centos.repo"
      {status} = await status.should.be.false()
      @fs.assert "#{tmpdir}/repo/centos.repo"
  
  they 'Write with content option', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.mkdir "#{tmpdir}/repo"
      {status} = await @tools.repo
        target: "#{tmpdir}/repo/centos.repo"
        content:
          'base':
            'name':'CentOS-$releasever - Base'
            'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck':'0'
      status.should.be.true()
      {status} = await @tools.repo
        target: "#{tmpdir}/repo/centos.repo"
        content:
          'base':
            'name':'CentOS-$releasever - Base'
            'baseurl':'http://mirror.centos.org/centos/$releasever/os/$basearch/'
            'gpgcheck':'0'
      status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/repo/centos.repo"
        content: '[base]\nname = CentOS-$releasever - Base\nbaseurl = http://mirror.centos.org/centos/$releasever/os/$basearch/\ngpgcheck = 0\n'
  
  they 'delete files with replace option', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/CentOS.repo"
        content: """
          [base]
          name=CentOS-$releasever - Base
          mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
          baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
          gpgcheck=1
          gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        """
      {status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        clean: 'test*'
      status.should.be.false()
      @file.touch
        target: "#{tmpdir}/test.repo"
      {status} = await @tools.repo
        source: "#{tmpdir}/CentOS.repo"
        clean: "#{tmpdir}/test*"
      status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/test.repo"
        not: true
  
  they 'Download GPG Keys option', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
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
      @tools.repo
        source: "#{tmpdir}/hdp-test.repo"
        gpg_dir: "#{tmpdir}"
        update: false
      @fs.assert "#{tmpdir}/RPM-GPG-KEY-Jenkins"
  
  they 'Download repo from remote location', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @fs.remove '/etc/yum.repos.d/hdp.repo'
      {status} = await @tools.repo
        source: "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/hdp.repo"
      status.should.be.true()
      {status} = await @tools.repo
        source: "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/hdp.repo"
      status.should.be.false()
      @fs.assert '/etc/yum.repos.d/hdp.repo'

  they 'Do Not update Package', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @fs.remove '/etc/yum.repos.d/mongodb.repo'
      @service.remove 'mongodb-org-shell'
      {status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.2':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
      status.should.be.true()
      {status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.2':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
      status.should.be.false()
      @service.install
        name: 'mongodb-org-shell'
      @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
      {status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      status.should.be.true()
      {status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      status.should.be.false()
      @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"

  they 'Update Package', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @fs.remove '/etc/yum.repos.d/mongodb.repo'
      @fs.remove '/etc/pki/rpm-gpg/server-3.2.asc'
      @fs.remove '/etc/pki/rpm-gpg/server-3.4.asc'
      @service.remove 'mongodb-org-shell'
      @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        content:
          'mongodb-org-3.2':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.2.asc'
      @service.install
        name: 'mongodb-org-shell'
      @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.2'"
      {status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        update: true
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      status.should.be.true()
      {status} = await @tools.repo
        target: '/etc/yum.repos.d/mongodb.repo'
        update: true
        content:
          'mongodb-org-3.4':
            'name':'MongoDB Repository'
            'baseurl':'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/'
            'gpgcheck':'1'
            'enabled':'1'
            'gpgkey':'https://www.mongodb.org/static/pgp/server-3.4.asc'
      status.should.be.false()
      @execute
        command: "mongo --version | grep shell | awk '{ print $4 }' | grep '3.4'"
