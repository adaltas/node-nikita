
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.unlink', ->
  return unless test.tags.posix

  they 'a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_target"
        content: 'hello'
      await @fs.unlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      @fs.exists
        target: "{{parent.metadata.tmpdir}}/a_target"
      .should.be.finally.containEql exists: false

  they 'a link referencing a directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.symlink
        source: "{{parent.metadata.tmpdir}}/a_dir"
        target: "{{parent.metadata.tmpdir}}/a_target"
      await @fs.unlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      await @fs.assert
        target: "{{parent.metadata.tmpdir}}/a_dir"
        filetype: 'directory'
      await @fs.assert
        target: "{{parent.metadata.tmpdir}}/a_target"
        not: true

  they 'error ENOENT', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      @fs.unlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      .should.be.rejectedWith
        code: 'NIKITA_FS_UNLINK_ENOENT'
        message: /NIKITA_FS_UNLINK_ENOENT: the file to remove does not exists, got ".*\/a_target"/

  they 'error EPERM', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.mkdir
        target: "{{parent.metadata.tmpdir}}/a_target"
      @fs.unlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      .should.be.rejectedWith
        code: 'NIKITA_FS_UNLINK_EPERM'
        message: /NIKITA_FS_UNLINK_EPERM: you do not have the permission to remove the file, got ".*\/a_target"/
