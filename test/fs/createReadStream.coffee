
nikita = require '../../src'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
test = require '../test'

describe 'fs.createReadStream', ->

  scratch = test.scratch @

  they 'option on_readable', (ssh) ->
    buffers = []
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .fs.createReadStream
      target: "#{scratch}/a_file"
      on_readable: (rs) ->
        while buffer = rs.read()
          buffers.push buffer
    , (err) ->
      Buffer.concat(buffers).toString().should.eql 'hello' unless err
    .promise()

  they 'option stream', (ssh) ->
    buffers = []
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .fs.createReadStream
      target: "#{scratch}/a_file"
      stream: (rs) ->
        rs.on 'readable', ->
          while buffer = rs.read()
            buffers.push buffer
    , (err) ->
      Buffer.concat(buffers).toString().should.eql 'hello' unless err
    .promise()
  
