
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service system discover', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_discover

  they 'they detect OS type and release', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/system-release | egrep '(Red\sHat)|(CentOS)'"
      handler: (options) ->
        mecano
          ssh: ssh
        .system.discover (err, status, os) ->
          #os object
          os.type.should.match /^((redhat)|(centos))/
          os.release.should.match /^[6|7]./
          status.should.be.false()
        .call (options) ->
          #store object
          options.store['mecano:system:type'].should.match /^((redhat)|(centos))/
          options.store['mecano:system:release'].should.match /^[6|7]./
        .then next
    .call
      if_exec: "cat /etc/lsb-release | egrep '(Ubuntu)'"
      handler: (options) ->
        mecano
          ssh: ssh
        .system.discover (err, status, os) ->
          #os object
          os.type.should.match /^(ubuntu)/
          os.release.should.match /^14./
          status.should.be.false()
        .call (options) ->
          #store object
          options.store['mecano:system:type'].should.match /^(ubuntu)/
          options.store['mecano:system:release'].should.match /^14./
        .then next
  
  they 'they do use cache', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/system-release | egrep '(Red\sHat)|(CentOS)'"
      handler: ->
        mecano
          ssh: ssh
          shy: false
        .system.discover (err, status) -> status.should.be.true()
        .system.discover (err, status) -> status.should.be.false()
        .then next
    .call
      if_exec: "cat /etc/lsb-release | egrep '(Ubuntu)'"
      handler: ->
        mecano
          ssh: ssh
          shy: false
        .system.discover (err, status) -> status.should.be.true()
        .system.discover (err, status) -> status.should.be.false()
        .then next

  they 'they do not use cache', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/system-release | egrep '(Red\sHat)|(CentOS)'"
      handler: ->
        mecano
          ssh: ssh
          cache: false
          shy: false
        .system.discover (err, status) -> status.should.be.true()
        .system.discover (err, status) -> status.should.be.true()
        .then next
    .call
      if_exec: "cat /etc/lsb-release | egrep '(Ubuntu)'"
      handler: ->
        mecano
          ssh: ssh
          cache: false
          shy: false
        .system.discover (err, status) -> status.should.be.true()
        .system.discover (err, status) -> status.should.be.true()
        .then next
