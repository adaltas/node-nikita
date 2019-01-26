
fs = require 'ssh2-fs'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'fs.read', ->

  they 'read a file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .call (_, callback) ->
      @fs.readFile
        target: "#{scratch}/a_file"
        encoding: 'ascii'
      , (err, {data}) ->
        data.toString().should.eql 'hello' unless err
        callback err
    .promise()
  
  describe 'error', ->
  
    they 'read a missing file', (ssh) ->
      validate_error = (err) ->
        err.message.should.eql "ENOENT: no such file or directory, open '#{scratch}/whereareu'"
        err.errno.should.eql -2
        err.code.should.eql 'ENOENT'
        err.syscall.should.eql 'open'
        err.path.should.eql "#{scratch}/whereareu"
      nikita
        ssh: ssh
      .call (_, callback) ->
        fs.readFile ssh, "#{scratch}/whereareu", (err) ->
          validate_error err
          callback()
      .fs.readFile target: "#{scratch}/whereareu", relax: true, (err) ->
        validate_error err
      .promise()
  
    they 'read a directory', (ssh) ->
      validate_error = (err) ->
        err.message.should.eql 'EISDIR: illegal operation on a directory, read'
        err.errno.should.eql -21
        err.code.should.eql 'EISDIR'
        err.syscall.should.eql 'read'
      nikita
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/a_dir"
      .call (_, callback) ->
        fs.readFile ssh, "#{scratch}/a_dir", (err) ->
          validate_error err
          callback()
      .fs.readFile target: "#{scratch}/a_dir", relax: true, (err) ->
        validate_error err
      .promise()
