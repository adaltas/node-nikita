
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.base.mkdir', ->
  return unless test.tags.posix

  they 'a new directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_directory"
      @fs.stat
        target: "{{parent.metadata.tmpdir}}/a_directory"
      .then ({stats}) ->
        utils.stats.isDirectory(stats.mode).should.be.true()

  they 'over an existing directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_directory"
      @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_directory"
      .should.be.rejectedWith
        message: /NIKITA_FS_MKDIR_TARGET_EEXIST: fail to create a directory, one already exists, location is ".+\/a_directory"/
        code: 'NIKITA_FS_MKDIR_TARGET_EEXIST',
        error_code: 'EEXIST',
        errno: -17,
        path: /.*\/a_directory/
        syscall: 'mkdir'
