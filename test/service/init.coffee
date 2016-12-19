
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
discover = require '../../src/misc/discover'

describe 'service render init scripts', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service
  process.env['TMPDIR'] = '/var/tmp' if config.isCentos6 or config.isCentos7

  if config.isCentos6

    they 'init file with target and source (default) CentOS/Redhat6', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove
        target: '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
        target: '/etc/init.d/crond'
      .file.assert '/etc/init.d/crond'
      .then next

    they 'init file with source only (default) CentOS/Redhat6', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove
        target: '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
      .file.assert '/etc/init.d/crond'
      .then next

    they 'init file with source and name (default) CentOS/Redhat6', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove
        target: '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
        name: 'crond-name'
      .file.assert '/etc/init.d/crond-name'
      .then next

  if config.isCentos7

    they 'init file with target and source (default) CentOS/Redhat7', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove
        target: '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
        target: '/etc/systemd/system/crond.service'
      .file.assert '/etc/systemd/system/crond.service'
      .then next

    they 'init file with source only (default) CentOS/Redhat7', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove
        target: '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
      .file.assert '/etc/systemd/system/crond.service'
      .then next

    they 'init file with source and name (default) CentOS/Redhat7', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove
        target: '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
        name: 'crond-name'
      .file.assert '/etc/systemd/system/crond-name.service'
      .then next

    they 'status not modified CentOS/Redhat7', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove '/etc/systemd/system/crond.service'
      .remove '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
      , (err, status) -> status.should.be.true()
      .service.init
        source: "#{__dirname}/crond.j2"
      , (err, status) -> status.should.be.false()
      .then next
          
    they 'init file to init.d legacy CentOS/Redhat7', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .service.install 'cronie'
      .remove '/etc/systemd/system/crond.service'
      .remove '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
        target: '/etc/init.d/crond'
      .service.start
        name: 'crond'
      , (err, started) -> started.should.be.true()
      .then next

    they 'status not modified daemon reload CentOS/Redhat7', (ssh, next) ->
      mecano
        ssh: ssh
      .service.remove 'cronie'
      .remove '/etc/systemd/system/crond.service'
      .remove '/etc/init.d/crond'
      .service.init
        source: "#{__dirname}/crond.j2"
        target: '/etc/init.d/crond'
      , (err, status) -> status.should.be.true()
      .service.init
        source: "#{__dirname}/crond.j2"
        target: '/etc/init.d/crond'
      , (err, status) -> status.should.be.false()
      .then next

      
