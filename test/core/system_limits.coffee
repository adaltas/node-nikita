
mecano = require '../../src'
they = require 'ssh2-they'
test = require '../test'
fs = require 'ssh2-fs'

describe 'system_limits', ->

  scratch = test.scratch @

  they 'do nothing without any limits', (ssh, next) ->
      mecano
        ssh: ssh
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
      , (err, status) ->
        return callback err if err
        status.should.be.false()
        fs.exists ssh, "#{scratch}/me.conf", (err, exists) ->
          exists.should.be.false() unless err
          next err

  they 'nofile and noproc accept int', (ssh, next) ->
      mecano
        ssh: ssh
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: 2048
        nproc: 2048
      , (err, status) ->
        return callback err if err
        status.should.be.true()
        fs.readFile ssh, "#{scratch}/me.conf", 'ascii', (err, content) ->
          content.should.eql """
          me    -    nofile   2048
          me    -    nproc   2048

          """ unless err
          next err


  they 'detect changes', (ssh, next) ->
      mecano
        ssh: ssh
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: 2048
        nproc: 2048
        shy: true
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: 2047
        nproc: 2047
      .then (err, status) ->
        status.should.be.true() unless err
        next err

  they 'detect no change', (ssh, next) ->
      mecano
        ssh: ssh
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: 2048
        nproc: 2048
        shy: true
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: 2048
        nproc: 2048
      .then (err, status) ->
        status.should.be.false() unless err
        next err

    they 'calculate nproc & nofile', (ssh, next) ->
      nproc = null
      nofile = null
      mecano
        ssh: ssh
      .execute
        cmd: 'cat /proc/sys/fs/file-max'
      , (err, status, stdout) ->
        return callback err if err
        nofile = stdout.trim()
      .execute
        cmd: 'cat /proc/sys/kernel/pid_max'
      , (err, status, stdout) ->
        return callback err if err
        nproc = stdout.trim()
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: true
        nproc: true
      , (err, status) ->
        return callback err if err
        status.should.be.true()
        fs.readFile ssh, "#{scratch}/me.conf", 'ascii', (err, content) ->
          content.should.eql """
          me    -    nofile   #{nofile}
          me    -    nproc   #{nproc}

          """ unless err
          next err
