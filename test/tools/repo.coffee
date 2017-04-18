
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'
fs = require 'ssh2-fs'

describe 'tools.repo', ->

  scratch = test.scratch @
  
  they 'Write simple file', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove "#{scratch}/repo"
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

describe 'tools.repo system', ->
  
  config = test.config()
  return if config.disable_tools_repo
  
  they 'Replace option to delete files', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove '/etc/yum.repos.d/CentOS-nikita.repo'
    .file.touch '/etc/yum.repos.d/test.repo'
    .tools.repo
      source: "#{__dirname}/../resources/CentOS-nikita.repo"
      replace: 'test*'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      source: "#{__dirname}/../resources/CentOS-nikita.repo"
      replace: 'test*'
    , (err, status) ->
      status.should.be.false() unless err
    .tools.repo
      source: "#{__dirname}/../resources/CentOS-nikita.repo"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert '/etc/yum.repos.d/CentOS-nikita.repo'
    .system.remove '/etc/yum.repos.d/CentOS-nikita.repo'
    .then next
  
  they 'Download GPG Keys option', (ssh, next) ->
    nikita
      ssh: ssh
    .system.remove '/etc/yum.repos.d/hdp-nikita.repo'
    .system.remove '/etc/pki/rpm-gpg/RPM-GPG-KEY-Jenkins'
    .tools.repo
      source: "#{__dirname}/../resources/hdp-nikita.repo"
    , (err, status) ->
      status.should.be.true() unless err
    .tools.repo
      source: "#{__dirname}/../resources/hdp-nikita.repo"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert '/etc/yum.repos.d/hdp-nikita.repo'
    .system.remove '/etc/yum.repos.d/hdp-nikita.repo'
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
