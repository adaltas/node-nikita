
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.exists', ->
  return unless test.tags.posix
  
  they 'does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @fs.exists
        target: "#{tmpdir}/not_here"
      .should.be.finally.containEql
        exists: false
        target: "#{tmpdir}/not_here"

  they 'exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @fs.writeFile
        target: "#{tmpdir}/a_file"
        content: "some content"
      @fs.exists
        target: "#{tmpdir}/a_file"
      .should.be.finally.containEql
        exists: true
        target: "#{tmpdir}/a_file"

  they 'option argument default to target', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: ''
      @fs.exists "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql exists: true
