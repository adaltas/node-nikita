
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
discover = require '../../src/misc/discover'

describe 'service system discover', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service
  process.env['TMPDIR'] = '/var/tmp' if config.isCentos6 or config.isCentos7
  
  if config.isCentos6
    they 'they detect service CentOS/Redhat 6', (ssh, next) ->
      mecano
        ssh: ssh
      .call discover.loader, ssh: ssh
      .call (options) ->
        options.store['mecano:service:loader'].should.match /^service/
      .then next

  if config.isCentos7
    they 'they detect systemd CentOS/Redhat 7', (ssh, next) ->
      mecano
        ssh: ssh
      .call discover.loader, ssh: ssh
      .call (options) ->
        options.store['mecano:service:loader'].should.match /^systemctl/
      .then next

  if config.isCentos6
    they 'they detect OS type and release CentOS/Redhat 6', (ssh, next) ->
      mecano
        ssh: ssh
      .call discover.system, ssh: ssh
      .call (options) ->
        options.store['mecano:system:type'].should.match /^((redhat)|(centos))/
        options.store['mecano:system:release'].should.match /^6./
      .then next

  if config.isCentos7
    they 'they detect OS type and release CentOS/Redhat 7', (ssh, next) ->
      mecano
        ssh: ssh
      .call discover.system, ssh: ssh
      .call (options) ->
        options.store['mecano:system:type'].should.match /^((redhat)|(centos))/
        options.store['mecano:system:release'].should.match /^7./
      .then next
  
