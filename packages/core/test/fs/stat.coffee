
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'fs.stat', ->

  they 'handle missing file', (ssh) ->
    nikita
      ssh: ssh
    .fs.stat
      target: "#{scratch}/not_here"
      relax: true
    , (err) ->
      err.code.should.eql 'ENOENT'
    .promise()

  they 'with a file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .fs.stat
      target: "#{scratch}/a_file"
    , (err, {stats}) ->
      return if err
      misc.stats.isFile(stats.mode).should.be.true()
      stats.mode.should.be.a.Number()
      stats.uid.should.be.a.Number()
      stats.gid.should.be.a.Number()
      stats.size.should.be.a.Number()
      stats.atime.should.be.a.Number()
      stats.mtime.should.be.a.Number()
    .promise()

  they 'with a directory', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .fs.stat
      target: "#{scratch}/a_dir"
    , (err, {stats}) ->
      return if err
      misc.stats.isDirectory(stats.mode).should.be.true()
    .promise()

  they 'with a file link', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_file"
    .fs.stat
      target: "#{scratch}/a_link"
    , (err, {stats}) ->
      return if err
      misc.stats.isFile(stats.mode).should.be.true()
      misc.stats.isSymbolicLink(stats.mode).should.be.false()
    .promise()

  they 'with a directory link', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_dir"
    .fs.stat
      target: "#{scratch}/a_link"
    , (err, {stats}) ->
      return if err
      misc.stats.isDirectory(stats.mode).should.be.true()
      misc.stats.isSymbolicLink(stats.mode).should.be.false()
    .promise()
