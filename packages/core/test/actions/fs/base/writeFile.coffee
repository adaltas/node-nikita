
import nikita from '@nikitajs/core'
import test from '../../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.writeFile', ->
  return unless test.tags.posix

  they 'content is a string', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
      @fs.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql data: Buffer.from 'some content'

  they 'content is empty', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: ''
      @fs.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql data: Buffer.from ''
  
  they 'option append on missing file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
        flags: 'a'
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        encoding: 'ascii'
      .should.be.finally.containEql data: 'some content'
  
  they 'option append on existing file', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some'
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'thing'
        flags: 'a'
      {data} = await @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        encoding: 'ascii'
      .should.be.finally.containEql data: 'something'
