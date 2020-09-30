
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.service_systemctl

describe 'service.init', ->
  
  @timeout 60000

  they 'init file with target and source (default)', ({ssh}) ->
    nikita
      ssh: ssh
    .service.remove 'cronie'
    .system.remove
      target: '/etc/init.d/crond'
    .service.init
      source: "#{__dirname}/crond.j2"
      target: '/etc/init.d/crond'
    .file.assert '/etc/init.d/crond'
    .promise()
  
  they 'init file with source only (default)', ({ssh}) ->
    nikita
      ssh: ssh
    .service.remove 'cronie'
    .system.remove
      target: '/etc/init.d/crond'
    .service.init
      source: "#{__dirname}/crond.j2"
    .file.assert '/etc/init.d/crond'
    .promise()
  
  they 'init file with source and name (default)', ({ssh}) ->
    nikita
      ssh: ssh
    .service.remove 'cronie'
    .system.remove
      target: '/etc/init.d/crond'
    .service.init
      source: "#{__dirname}/crond.j2"
      name: 'crond-name'
    .file.assert '/etc/init.d/crond-name'
    .promise()
  
  describe 'daemon-reload', ->
  
    they 'with systemctl sysv-generator', ({ssh}) ->
      nikita
        ssh: ssh
        if_os: name: ['redhat','centos'], version: '7'
      .service.remove 'cronie'
      .service.install 'cronie'
      .system.remove
        target: '/etc/init.d/crond'
      .system.execute
        cmd: 'systemctl daemon-reload;systemctl reset-failed'
      .service.init
        source: "#{__dirname}/crond.j2"
        name: 'crond'
      .file.assert '/etc/init.d/crond'
      .service.start
        name: 'crond'
      .service.start
        name: 'stop'
      .promise()

    they 'daemon-reload with systemctl systemd script', ({ssh}) ->
      nikita
        ssh: ssh
      .call
        if_os: name: ['redhat','centos'], version: '7'
      , ->
        @service.remove 'cronie'
        @service.install 'cronie'
        @system.remove
          target: '/etc/init.d/crond'
        @system.remove
          target: '/usr/lib/systemd/system/crond.service'
        @service.init
          source: "#{__dirname}/crond-systemd.j2"
          context: description: 'Command Scheduler Test 1'
          target: '/usr/lib/systemd/system/crond.service'
        , (err, {status}) ->
          status.should.be.true() unless err
        @file.assert '/usr/lib/systemd/system/crond.service'
        @service.start
          name: 'crond'
      .promise()
