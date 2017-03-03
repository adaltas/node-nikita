
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.discover', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_discover

  they 'return info on RH', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/system-release | egrep '(Red\sHat)|(CentOS)'"
    , ->
      @system.discover (err, status, info) ->
        info.type.should.match /^((redhat)|(centos))/ unless err
        info.release.should.match /^[6|7]./ unless err
    .then next

  they 'return info on Ubuntu', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/lsb-release | egrep '(Ubuntu)'"
    , ->
      @system.discover (err, status, info) ->
        info.type.should.match /^(ubuntu)/
        info.release.should.match /^\d+./
    .then next

  they 'dont cache by default on RH', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/system-release | egrep '(Red\sHat)|(CentOS)'"
    , ->
      @system.discover (err, status) -> status.should.be.true() unless err
      @system.discover (err, status) -> status.should.be.true() unless err
    .then next

  they 'dont cache by default on Ubuntu', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/lsb-release | egrep '(Ubuntu)'"
    , ->
      @system.discover (err, status) -> status.should.be.true() unless err
      @system.discover (err, status) -> status.should.be.true() unless err
    .then next

  they 'honors cache on RH', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/system-release | egrep '(Red\sHat)|(CentOS)'"
    , ->
      @system.discover cache: true, (err, status) -> status.should.be.true() unless err
      @system.discover cache: true, (err, status) -> status.should.be.false() unless err
      @call (options) ->
        options.store['mecano:system:type'].should.match /^((redhat)|(centos))/
        options.store['mecano:system:release'].should.match /^[6|7]./
    .then next

  they 'honors cache on Ubuntu', (ssh, next) ->
    mecano
      ssh: ssh
    .call
      if_exec: "cat /etc/lsb-release | egrep '(Ubuntu)'"
    , ->
      @system.discover cache: true, (err, status) -> status.should.be.true() unless err
      @system.discover cache: true, (err, status) -> status.should.be.false() unless err
      @call (options) ->
        options.store['mecano:system:type'].should.match /^(ubuntu)/
        options.store['mecano:system:release'].should.match /^\d+./
    .then next
