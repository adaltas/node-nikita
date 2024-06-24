
import nikita from '@nikitajs/core'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.writeFile.sudo', ->
  return unless test.tags.sudo

  they 'owner is root', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
      $sudo: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
      {stats} = await @fs.stat "{{parent.metadata.tmpdir}}/a_file"
      stats.uid.should.eql 0
      stats.gid.should.eql 0

      
