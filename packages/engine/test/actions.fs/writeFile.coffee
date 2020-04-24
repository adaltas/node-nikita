
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'fs.writeFile', ->

  they 'content is a string', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
      @fs.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith 'some content'

  they 'content is empty', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: ''
      @fs.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith ''
  
  they.skip 'option append on missing file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
        flags: 'a'
      @fs.readFile "{{parent.metadata.tmpdir}}/a_file"
      .should.be.resolvedWith 'some content'
  
  they.skip 'option append on existing file', ({ssh}) ->
    # TODO, for now, this test fail with `some` instead of `something`,
    # The flag is provided to ssh2-fs and there is a test inside it validating
    # its behavior, no time to investigate and we shall wait for `dirty` which
    # will help the debugging
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some'
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'thing'
        flags: 'a'
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'something'
