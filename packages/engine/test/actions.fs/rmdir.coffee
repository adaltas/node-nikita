
fs = require 'ssh2-fs'
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.rmdir', ->

  they 'remove', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.mkdir
        target: "{{parent.metadata.tmpdir}}/a_file"
      @fs.rmdir
        target: "{{parent.metadata.tmpdir}}/a_file"
      @fs.exists
        target: "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith false

  they 'error missing', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.rmdir
        target: "{{parent.metadata.tmpdir}}/missing"
      .should.be.rejectedWith
        code: 'NIKITA_FS_RMDIR_TARGET_ENOENT'
        message: /NIKITA_FS_RMDIR_TARGET_ENOENT: fail to remove a directory, target is not a directory, got ".*\/missing"/
        exit_code: 2
        errno: -2
        syscall: 'rmdir'
        path: /.*\/missing/
