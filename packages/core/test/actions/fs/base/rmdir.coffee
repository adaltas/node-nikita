
import fs from 'ssh2-fs'
import nikita from '@nikitajs/core'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.rmdir', ->
  return unless test.tags.posix

  they 'dir is removed', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.rmdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      @fs.exists
        target: "{{parent.metadata.tmpdir}}/a_dir"
      .should.be.finally.containEql exists: false

  they 'config recursive false, default', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_dir/a_file"
        content: ''
      @fs.rmdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      .should.be.rejectedWith
        code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID'

  they 'config recursive true', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_dir/a_file"
        content: ''
      await @fs.rmdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
        recursive: true
      await @fs.assert
        target: "{{parent.metadata.tmpdir}}/a_dir"
        not: true

  they 'NIKITA_FS_RMDIR_TARGET_ENOENT target does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
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
