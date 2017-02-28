
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.init', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service
  process.env['TMPDIR'] = '/var/tmp'


  they 'init file with target and source (default)', (ssh, next) ->
    mecano
      ssh: ssh
    .service.remove 'cronie'
    .system.remove
      target: '/etc/init.d/crond'
    .service.init
      source: "#{__dirname}/crond.j2"
      target: '/etc/init.d/crond'
    .file.assert '/etc/init.d/crond'
    .then next

  they 'init file with source only (default)', (ssh, next) ->
    mecano
      ssh: ssh
    .service.remove 'cronie'
    .system.remove
      target: '/etc/init.d/crond'
    .service.init
      source: "#{__dirname}/crond.j2"
    .file.assert '/etc/init.d/crond'
    .then next

  they 'init file with source and name (default)', (ssh, next) ->
    mecano
      ssh: ssh
    .service.remove 'cronie'
    .system.remove
      target: '/etc/init.d/crond'
    .service.init
      source: "#{__dirname}/crond.j2"
      name: 'crond-name'
    .file.assert '/etc/init.d/crond-name'
    .then next

  #redhat 7
  # they 'init file with target and source (default)', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.remove 'cronie'
  #   .system.remove
  #     target: '/etc/init.d/crond'
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #     target: '/etc/systemd/system/crond.service'
  #   .file.assert '/etc/systemd/system/crond.service'
  #   .then next
  # 
  # they 'init file with source only (default)', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.remove 'cronie'
  #   .system.remove
  #     target: '/etc/init.d/crond'
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #   .file.assert '/etc/systemd/system/crond.service'
  #   .then next
  # 
  # they 'init file with source and name (default)', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.remove 'cronie'
  #   .system.remove
  #     target: '/etc/init.d/crond'
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #     name: 'crond-name'
  #   .file.assert '/etc/systemd/system/crond-name.service'
  #   .then next
  # 
  # they 'status not modified', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.remove 'cronie'
  #   .system.remove '/etc/systemd/system/crond.service'
  #   .system.remove '/etc/init.d/crond'
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #   , (err, status) -> status.should.be.true()
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #   , (err, status) -> status.should.be.false()
  #   .then next
  #       
  # they 'init file to init.d legacy CentOS/Redhat7', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.remove 'cronie'
  #   .service.install 'cronie'
  #   .system.remove '/etc/systemd/system/crond.service'
  #   .system.remove '/etc/init.d/crond'
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #     target: '/etc/init.d/crond'
  #   .service.start
  #     name: 'crond'
  #   , (err, started) -> started.should.be.true()
  #   .then next
  # 
  # they 'status not modified daemon reload CentOS/Redhat7', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.remove 'cronie'
  #   .system.remove '/etc/systemd/system/crond.service'
  #   .system.remove '/etc/init.d/crond'
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #     target: '/etc/init.d/crond'
  #   , (err, status) -> status.should.be.true()
  #   .service.init
  #     source: "#{__dirname}/crond.j2"
  #     target: '/etc/init.d/crond'
  #   , (err, status) -> status.should.be.false()
  #   .then next
  # 
  #   
