
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'tools.compress', ->

  they 'should see extension .tgz', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'some content'
    .tools.compress
      source: "#{scratch}/a_dir/a_file"
      target: "#{scratch}/a_dir.tgz"
    , (err, {status}) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir.tgz"
    .promise()

  they 'should see extension .zip', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'some content'
    .tools.compress
      source: "#{scratch}/a_dir/a_file"
      target: "#{scratch}/a_dir.zip"
    , (err, {status}) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir.zip"
    .promise()

  they 'should see extension .tar.bz2', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'some content'
    .tools.compress
      source: "#{scratch}/a_dir/a_file"
      target: "#{scratch}/a_dir.tar.bz2"
    , (err, {status}) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir.tar.bz2"
    .promise()

  they 'should see extension .tar.xz', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'some content'
    .tools.compress
      source: "#{scratch}/a_dir/a_file"
      target: "#{scratch}/a_dir.tar.xz"
    , (err, {status}) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir.tar.xz"
    .promise()
  
  they 'remove source file with clean option', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'hellow'
    .tools.compress
      source: "#{scratch}/a_dir/a_file"
      target: "#{scratch}/a_dir.tar.xz"
      clean: true
    , (err, {status}) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir/a_file"
      not: true
    .promise()
  
  they 'remove source directory with clean option', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'hellow'
    .tools.compress
      source: "#{scratch}/a_dir"
      target: "#{scratch}/a_dir.tar.xz"
      clean: true
    , (err, {status}) ->
      status.should.be.true()
    .file.assert
      source: "#{scratch}/a_dir"
      not: true
    .promise()

  they 'should pass error for invalid extension', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.compress
      source: __filename
      target: __filename
      relax: true
    , (err) ->
      err.message.should.eql 'Unsupported Extension: ".coffee"'
    .promise()
