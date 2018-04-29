
nikita = require '../../src'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
test = require '../test'

describe 'fs.createWriteStream', ->

  scratch = test.scratch @

  they 'write a file', (ssh) ->
    buffers = []
    nikita
      ssh: ssh
    .fs.createWriteStream
      target: "#{scratch}/a_file"
      stream: (ws) ->
        ws.write 'hello'
        ws.end()
    .file.assert
      target: "#{scratch}/a_file"
      content: 'hello'
    .promise()

  they 'throw error if parent direction does not exist', (ssh) ->
    buffers = []
    nikita
      ssh: ssh
    .fs.createWriteStream
      target: "#{scratch}/a_dir/a_file"
      stream: (ws) ->
        ws.write 'hello'
        ws.end()
      relax: true
    , (err) ->
      err.message.should.eql "ENOENT: no such file or directory, open '#{scratch}/a_dir/a_file'"
      err.errno.should.eql -2
      err.code.should.eql 'ENOENT'
      err.syscall.should.eql 'open'
      err.path.should.eql "#{scratch}/a_dir/a_file"
    .promise()
  
