
nikita = require '../../src'
fs = require('fs').promises
{Dirent} = require 'fs'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'fs.readdir', ->
  
  it 'get native behavior', ->
    await fs.mkdir "#{scratch}/parent"
    await fs.mkdir "#{scratch}/parent/a_dir"
    await fs.writeFile "#{scratch}/parent/file_1"
    await fs.writeFile "#{scratch}/parent/file_2"
    # No options
    files = await fs.readdir "#{scratch}/parent"
    files.should.eql ['a_dir', 'file_1', 'file_2']
    # Option `withFileTypes`
    files = await fs.readdir "#{scratch}/parent", withFileTypes: true
    files
    .sort()
    .map (file) -> JSON.parse JSON.stringify file # Convert Dirent to object literal
    .should.eql [
      { name: 'a_dir' }
      { name: 'file_1' }
      { name: 'file_2' }
    ]
    files[0].isDirectory().should.be.true()
    files[1].isFile().should.be.true()

  they 'target option as argument', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.mkdir "#{scratch}/parent"
    .fs.mkdir "#{scratch}/parent/a_dir"
    .fs.writeFile "#{scratch}/parent/file_1", content: 'hello'
    .fs.writeFile "#{scratch}/parent/file_2", content: 'hello'
    .fs.readdir "#{scratch}/parent", (err, {files}) ->
      files.sort().should.eql ['a_dir', 'file_1', 'file_2'] unless err
    .promise()

  they 'target does not exist', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.readdir "#{scratch}/missing", relax: true, (err, {files}) ->
      err.message.should.eql "Invalid command: exit code is 1, ensure the target path \"#{scratch}/missing\" exists (nikita/lib/fs/readdir)"
    .promise()

  they 'handle missing file', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.mkdir "#{scratch}/parent"
    .fs.mkdir "#{scratch}/parent/a_dir"
    .fs.writeFile "#{scratch}/parent/file_1", content: 'hello'
    .fs.writeFile "#{scratch}/parent/file_2", content: 'hello'
    .fs.readdir "#{scratch}/parent", withFileTypes: true, (err, {files}) ->
      throw err if err
      files = files.sort()
      files.map (file) -> JSON.parse JSON.stringify file # Convert Dirent to object literal
      .should.eql [
        { name: 'a_dir' }
        { name: 'file_1' }
        { name: 'file_2' }
      ]
      files[0].isDirectory().should.be.true()
      files[1].isFile().should.be.true()
    .promise()
