
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.base.symlink', ->
  return unless test.tags.posix

  they 'create', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: 'hello'
      await @fs.base.symlink
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_target"
      {stats} = await @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/a_target"
        dereference: false
      utils.stats.isSymbolicLink(stats.mode).should.be.true()
