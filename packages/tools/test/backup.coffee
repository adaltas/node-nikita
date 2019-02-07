
nikita = require '@nikitajs/core'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'tools.backup', ->

  describe 'file', ->

    they 'backup to a directory', (ssh) ->
      nikita
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
      , (err, {status, filename}) ->
        status.should.be.true() unless err
        @file.assert
          target: "#{scratch}/backup/my_backup/#{filename}"
          filetype: 'file'
      .wait 1000
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
      , (err, {status, filename}) ->
        status.should.be.true() unless err
        @file.assert
          target: "#{scratch}/backup/my_backup/#{filename}"
          filetype: 'file'
      .promise()

    they 'compress', (ssh) ->
      nikita
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        source: "#{__filename}"
        target: "#{scratch}/backup"
        compress: true
      , (err, {status, filename}) ->
        status.should.be.true() unless err
        @file.assert
          target: "#{scratch}/backup/my_backup/#{filename}.tgz"
          filetype: 'file'
      .promise()

  describe 'cmd', ->

    they 'pipe to a file', (ssh) ->
      nikita
        ssh: ssh
      .tools.backup
        name: 'my_backup'
        cmd: "echo hello"
        target: "#{scratch}/backup"
      , (err, {status, filename}) ->
        status.should.be.true() unless err
        @file.assert
          target: "#{scratch}/backup/my_backup/#{filename}"
          content: "hello\n"
      .promise()
