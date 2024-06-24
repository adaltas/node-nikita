
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.lstat', ->
  return unless test.tags.posix

  they 'with a file link', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      await @fs.symlink
        target: "{{parent.metadata.tmpdir}}/a_link"
        source: "{{parent.metadata.tmpdir}}/a_file"
      @fs.lstat
        target: "{{parent.metadata.tmpdir}}/a_link"
      .then ({stats}) ->
        utils.stats.isFile(stats.mode).should.be.false()
        utils.stats.isSymbolicLink(stats.mode).should.be.true()

  they 'with a directory link', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.mkdir
        target: "{{parent.metadata.tmpdir}}/a_dir"
      await @fs.symlink
        target: "{{parent.metadata.tmpdir}}/a_link"
        source: "{{parent.metadata.tmpdir}}/a_dir"
      @fs.lstat
        target: "{{parent.metadata.tmpdir}}/a_link"
      .then ({stats}) ->
        utils.stats.isDirectory(stats.mode).should.be.false()
        utils.stats.isSymbolicLink(stats.mode).should.be.true()

  they 'option argument default to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: ''
      await @fs.symlink
        target: "{{parent.metadata.tmpdir}}/a_target"
        source: "{{parent.metadata.tmpdir}}/a_source"
      @fs.lstat
        target: "{{parent.metadata.tmpdir}}/a_target"
      .then ({stats}) ->
        utils.stats.isSymbolicLink(stats.mode).should.be.true()
