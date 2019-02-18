
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'fs.createReadStream', ->

  they 'option on_readable', ({ssh}) ->
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

  they 'option stream', ({ssh}) ->
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
  
