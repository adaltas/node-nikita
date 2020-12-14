
nikita = require '../../../../src'
{tags, ssh} = require '../../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.base.writeFile', ->

  they 'content is a string', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
      @fs.base.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql data: Buffer.from 'some content'

  they 'content is empty', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: ''
      @fs.base.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql data: Buffer.from ''
  
  they.skip 'option append on missing file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
        flags: 'a'
      @fs.base.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.finally.containEql data: Buffer.from 'some content'
  
  they.skip 'option append on existing file', ({ssh}) ->
    # TODO, for now, this test fail with `some` instead of `something`,
    # The flag is provided to ssh2-fs and there is a test inside it validating
    # its behavior, no time to investigate and we shall wait for `dirty` which
    # will help the debugging
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some'
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'thing'
        flags: 'a'
      @fs.base.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'something'
