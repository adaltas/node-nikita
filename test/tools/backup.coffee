
mecano = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.backup', ->

  scratch = test.scratch @

  describe 'file', ->

    they 'backup to a directory', (ssh, next) ->
      mecano
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
      , (err, status, info) ->
        status.should.be.true() unless err
        @system.execute "[ -f #{scratch}/backup/my_backup/#{info.filename} ]" unless err
      .wait 1000
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
      , (err, status, info) ->
        status.should.be.true() unless err
        @system.execute "[ -f #{scratch}/backup/my_backup/#{info.filename} ]" unless err
      .then next

    they 'compress', (ssh, next) ->
      mecano
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
        compress: true
      , (err, status, info) ->
        status.should.be.true() unless err
        @system.execute "[ -f #{scratch}/backup/my_backup/#{info.filename}.tgz ]" unless err
      .then next
