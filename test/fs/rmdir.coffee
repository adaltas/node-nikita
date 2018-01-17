
nikita = require '../../src'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
test = require '../test'

describe 'fs.rmdir', ->

  scratch = test.scratch @

  they 'remove', (ssh) ->
    nikita
      ssh: ssh
    .fs.mkdir
      target: "#{scratch}/a_file"
    .fs.rmdir
      target: "#{scratch}/a_file"
    .file.assert
      target: "#{scratch}/a_file"
      not: true
    .promise()

  they 'error missing', (ssh) ->
    validate_error = (err) ->
      err.message.should.eql "ENOENT: no such file or directory, rmdir '#{scratch}/missing'"
      err.errno.should.eql -2
      err.code.should.eql 'ENOENT'
      err.syscall.should.eql 'rmdir'
      err.path.should.eql "#{scratch}/missing"
    nikita
      ssh: ssh
    .call ->
      fs.rmdir ssh, "#{scratch}/missing", (err) ->
        validate_error err
    .fs.rmdir
      target: "#{scratch}/missing"
      relax: true
    , (err) ->
      validate_error err
    .file.assert
      target: "#{scratch}/missing"
      not: true
    .promise()
