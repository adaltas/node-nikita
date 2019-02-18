
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'fs.lstat', ->

  they 'with a file link', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_file"
    .fs.lstat
      target: "#{scratch}/a_link"
    , (err, {stats}) ->
      return if err
      misc.stats.isFile(stats.mode).should.be.false()
      misc.stats.isSymbolicLink(stats.mode).should.be.true()
    .promise()

  they 'with a directory link', ({ssh}) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_dir"
    .fs.lstat
      target: "#{scratch}/a_link"
    , (err, {stats}) ->
      return if err
      misc.stats.isDirectory(stats.mode).should.be.false()
      misc.stats.isSymbolicLink(stats.mode).should.be.true()
    .promise()

  they 'option argument default to target', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_source"
    .system.link
      target: "#{scratch}/a_target"
      source: "#{scratch}/a_source"
    .fs.lstat
      target: "#{scratch}/a_target"
    , (err, {stats}) ->
      misc.stats.isSymbolicLink(stats.mode).should.be.true() unless err
    .promise()
