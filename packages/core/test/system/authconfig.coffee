
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('mocha-they')(config)...

return unless tags.system_authconfig

describe 'system.authconfig', ->
    
  they 'edit empty sysconfig file', ({sudo ,ssh}) ->
    # Note, after authconfig package installation,
    # the configuration file exists and is empty
    mkhomedir = true
    nikita
      ssh: ssh
      sudo: sudo
    .call ->
      # Init
      @system.authconfig
        target: '/etc/sysconfig/authconfig'
        config:
          mkhomedir: mkhomedir
      # Change to negative
      @system.authconfig
        target: '/etc/sysconfig/authconfig'
        config: {
          mkhomedir: !mkhomedir
        }
      , (err, {status}) ->
        status.should.be.true() unless err
      # Preserve negative
      @system.authconfig
        target: '/etc/sysconfig/authconfig'
        config:
          mkhomedir: !mkhomedir
      , (err, {status}) ->
        status.should.be.false() unless err
      # Change to positive
      @system.authconfig
        target: '/etc/sysconfig/authconfig'
        config:
          mkhomedir: mkhomedir
      , (err, {status}) ->
        status.should.be.true() unless err
        @system.authconfig
          target: '/etc/sysconfig/authconfig'
          config:
            mkhomedir: mkhomedir
        , (err, {status}) ->
          status.should.be.false() unless err
    .promise()
    
