
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.stat', ->

  they 'handle missing file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.stat
      target: "{{parent.metadata.tmpdir}}/not_here"
    .should.be.rejectedWith
      code: 'NIKITA_FS_STAT_TARGET_ENOENT'
      message: /NIKITA_FS_STAT_TARGET_ENOENT: failed to stat the target, no file exists for target, got ".*"/

  they 'with a file', ({ssh}) ->
    {stats} = await nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_file"
      content: 'hello'
    .fs.stat
      target: "{{parent.metadata.tmpdir}}/a_file"
    utils.stats.isFile(stats.mode).should.be.true()
    stats.mode.should.be.a.Number()
    stats.uid.should.be.a.Number()
    stats.gid.should.be.a.Number()
    stats.size.should.be.a.Number()
    stats.atime.should.be.a.Number()
    stats.mtime.should.be.a.Number()

  they 'with a directory', ({ssh}) ->
    {stats} = await nikita
      ssh: ssh
      tmpdir: true
    .fs.mkdir
      target: "{{parent.metadata.tmpdir}}/a_dir"
    .fs.stat
      target: "{{parent.metadata.tmpdir}}/a_dir"
    utils.stats.isDirectory(stats.mode).should.be.true()

  they 'with a file link', ({ssh}) ->
    {stats} = await nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_file"
      content: 'hello'
    .fs.symlink
      target: "{{parent.metadata.tmpdir}}/a_link"
      source: "{{parent.metadata.tmpdir}}/a_file"
    .fs.lstat
      target: "{{parent.metadata.tmpdir}}/a_link"
    utils.stats.isFile(stats.mode).should.be.false()
    utils.stats.isSymbolicLink(stats.mode).should.be.true()

  they 'with a directory link', ({ssh}) ->
    {stats} = await nikita
      ssh: ssh
      tmpdir: true
    .fs.mkdir
      target: "{{parent.metadata.tmpdir}}/a_dir"
    .fs.symlink
      target: "{{parent.metadata.tmpdir}}/a_link"
      source: "{{parent.metadata.tmpdir}}/a_dir"
    .fs.lstat
      target: "{{parent.metadata.tmpdir}}/a_link"
    utils.stats.isDirectory(stats.mode).should.be.false()
    utils.stats.isSymbolicLink(stats.mode).should.be.true()
