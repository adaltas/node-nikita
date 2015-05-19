
mecano = require "../lib"
they = require 'ssh2-they'
test = require './test'
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
        status.should.be.false
        fs.exists ssh, "#{scratch}/me.conf", (err, exists) ->
          exists.should.be.false unless err
          next err

  they 'nofile and noprocs accept int', (ssh, next) ->
      mecano
        ssh: ssh
      .system_limits
        destination: "#{scratch}/me.conf"
        user: 'me'
        nofile: 2048
        nproc: 2048
      , (err, status) ->
        return callback err if err
        status.should.be.true
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
        nofile: 2048
        nproc: 2048
      .then (err, status) ->
        status.should.be.false unless err
        next err





