
nikita = require '../../src'
{tags, ssh,scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.sudo

describe 'options "sudo"', ->

  they 'readFile', ({ssh}) ->
    nikita
      ssh: ssh
      sudo: false
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
      uid: 0
      gid: 0
      # mode: 600
      sudo: true
    .call (_, callback) ->
      @fs.readFile
        target: "#{scratch}/a_file"
        encoding: 'ascii'
      , (err, {data}) ->
        data.should.eql 'hello' unless err
        callback err
    .promise()

  they 'writeFile', ({ssh}) ->
    uid = gid = null
    nikita
      ssh: ssh
      sudo: false
    .system.execute
      cmd: 'id -u && id -g'
    , (err, {stdout}) ->
      throw err if err
      [uid, gid] = stdout.split '\n'
    .fs.mkdir
      target: "#{scratch}/a_dir"
    .fs.chown
      target: "#{scratch}/a_dir"
      uid: 0
      gid: 0
      sudo: true
    .fs.writeFile
      target: "#{scratch}/a_dir/a_file"
      content: 'some content'
      sudo: true
    .call ->
      @file.assert
        target: "#{scratch}/a_dir/a_file"
        content: 'some content'
        uid: uid
        gid: gid
    .fs.unlink
      target: "#{scratch}/a_dir/a_file"
      sudo: true
    .fs.rmdir
      target: "#{scratch}/a_dir"
      sudo: true
    .promise()
  
  they 'execute', ({ssh}) ->
    nikita
      ssh: ssh
      sudo: false
    .system.execute.assert
      cmd: 'whoami'
      content: 'root'
      sudo: true
      trim: true
    .promise()
    
