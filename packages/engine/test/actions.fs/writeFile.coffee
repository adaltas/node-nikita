
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'fs.writeFile', ->

  they 'content is a string', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.writeFile
        target: "#{tmpdir}/a_file"
        content: 'some content'
      @fs.readFile "#{tmpdir}/a_file"
      .should.be.resolvedWith 'some content'

  they 'content is empty', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.writeFile
        target: "#{tmpdir}/a_file"
        content: ''
      @fs.readFile "#{tmpdir}/a_file"
      .should.be.resolvedWith ''
  
  they.skip 'option append on missing file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.writeFile
        target: "#{tmpdir}/a_file"
        content: 'some content'
        flags: 'a'
      @fs.readFile "#{tmpdir}/a_file"
      .should.be.resolvedWith 'some content'
  
  they.skip 'option append on existing file', ({ssh}) ->
    nikita
      ssh: ssh
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: 'some'
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: 'thing'
      flags: 'a'
    .file.assert
      target: "#{scratch}/a_file"
      content: 'something'
