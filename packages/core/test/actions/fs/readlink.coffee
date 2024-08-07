
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.readlink', ->
  return unless test.tags.posix

  they 'get value', ({ssh}) ->
    await nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: ''
      await @fs.symlink
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_target"
      {target} = await @fs.readlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      target.should.eql "#{tmpdir}/a_source"
