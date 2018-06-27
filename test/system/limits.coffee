
os = require 'os'
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'system.limits', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_system_limits

  they 'do nothing without any limits', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/me.conf"
      not: true
    .promise()

  they 'nofile and noproc accept int', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 2048
      nproc: 2048
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/me.conf"
      content: """
      me    -    nofile    2048
      me    -    nproc    2048
      
      """
    .promise()

  they 'set global value', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      system: true
      nofile: 2048
      nproc: 2048
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/me.conf"
      content: """
      *    -    nofile    2048
      *    -    nproc    2048
      
      """
    .promise()

  they 'specify hard and soft values', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile:
        soft: 2048
        hard: 4096
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/me.conf"
      content: """
      me    soft    nofile    2048
      me    hard    nofile    4096
      
      """
    .promise()

  they 'detect changes', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 2048
      nproc: 2048
      shy: true
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 2047
      nproc: 2047
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'detect no change', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 2048
      nproc: 2048
      shy: true
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 2048
      nproc: 2048
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'nofile and noproc default to 75% of kernel limits', (ssh) ->
    nproc = null
    nofile = null
    nikita
      ssh: ssh
    .file.assert
      target: '/proc/sys/fs/file-max'
    .system.execute
      cmd: 'cat /proc/sys/fs/file-max'
    , (err, {status, stdout}) ->
      return next err if err
      nofile = stdout.trim()
      nofile = Math.round parseInt(nofile)*0.75
    .system.execute
      cmd: 'cat /proc/sys/kernel/pid_max'
    , (err, {status, stdout}) ->
      return next err if err
      nproc = stdout.trim()
      nproc = Math.round parseInt(nproc)*0.75
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: true
      nproc: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .call ->
      @file.assert
        target: "#{scratch}/me.conf"
        content: """
        me    -    nofile    #{nofile}
        me    -    nproc    #{nproc}

        """
    .promise()

  they 'raise an error if nofile is too high', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 1000000000
      relax: true
    , (err, {status}) ->
      err.message.should.match /^Invalid nofile options.*$/
    .promise()

  they 'raise an error if nproc is too high', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nproc: 1000000000
      relax: true
    , (err, {status}) ->
      err.message.should.match /^Invalid nproc options.*$/
    .promise()

  they 'raise an error if hardness is incoherent', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nproc:
        hard: 12
        toto: 24
      relax: true
    , (err, {status}) ->
      err.message.should.match /^Invalid option.*$/
    .promise()

  they 'accept value \'unlimited\'', (ssh) ->
    nikita
      ssh: ssh
    .system.limits
      target: "#{scratch}/me.conf"
      user: 'me'
      nofile: 2048
      nproc: 'unlimited'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/me.conf"
      content: """
      me    -    nofile    2048
      me    -    nproc    unlimited

      """
    .promise()
