
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.backup', ->

  scratch = test.scratch @

  describe 'file', ->

    they 'backup to a directory', (ssh, next) ->
      nikita
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
      nikita
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
        compress: true
      , (err, status, info) ->
        throw err if err
        status.should.be.true()
        @system.execute "[ -f #{scratch}/backup/my_backup/#{info.filename}.tgz ]"
      .then next

  describe 'cmd', ->

    they 'pipe to a file', (ssh, next) ->
      nikita
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        cmd: "echo hello"
        target: "#{scratch}/backup"
      , (err, status, info) ->
        throw err if err
        status.should.be.true()
        @file.assert
          target: "#{scratch}/backup/my_backup/#{info.filename}"
          content: "hello\n"
      .then next
