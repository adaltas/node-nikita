
fs = require 'ssh2-fs'
nikita = require '../../../../src'
{tags, ssh} = require '../../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.base.rmdir', ->

  they 'remove', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ->
      @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_file"
      @fs.base.rmdir
        target: "{{parent.metadata.tmpdir}}/a_file"
      @fs.base.exists
        target: "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql exists: false

  they 'NIKITA_FS_RMDIR_TARGET_ENOENT target does not exists', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ->
      @fs.base.rmdir
        target: "{{parent.metadata.tmpdir}}/missing"
      .should.be.rejectedWith
        code: 'NIKITA_FS_RMDIR_TARGET_ENOENT'
        message: /NIKITA_FS_RMDIR_TARGET_ENOENT: fail to remove a directory, target is not a directory, got ".*\/missing"/
        exit_code: 2
        errno: -2
        syscall: 'rmdir'
        path: /.*\/missing/
