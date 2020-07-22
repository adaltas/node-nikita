
nikita = require '@nikitajs/engine/src'
{tags, ssh, tmpdir} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file options diff', ->

  they 'type.only is a function', ({ssh}) ->
    diffcalled = false
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file"
        content: 'Testing diff\noriginal text'
      @file
        target: "#{tmpdir}/file"
        content: 'Testing diff\nnew text'
        diff: (text, diff) ->
          diffcalled = true
          diff.should.eql [
            { value: 'Testing diff\n', count: 1 }
            { value: 'original text', count: 1, added: undefined, removed: true }
            { value: 'new text', count: 1, added: true, removed: undefined }
          ]
      .should.be.resolvedWith status: true

  they.skip 'emit logs', ({ssh}) ->
    # Prepare by creating a file with content
    logs = []
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @on 'diff', (log) -> logs.push log.message
      @file
        target: "#{tmpdir}/file"
        content: 'Testing diff\noriginal text'
      @file
        target: "#{tmpdir}/file"
        content: 'Testing diff\nnew text'
      @call ->
        logs.should.eql [
          '1 + Testing diff\n2 + original text\n'
          '2 - original text\n2 + new text\n'
        ]

  they 'write a buffer', ({ssh}) ->
    # Passing a buffer as content resulted to a diff error
    # with message "#{content} has no method 'split'",
    # make sure this is fixed for ever
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file"
        content: Buffer.from 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMKgZ7/2BG9T0vCJT8qlaH1KJNLSqEiJDHZMirPdzVsbI8x1AiT0EO5D47aROAKXTimVY3YsFr2ETXbLxjFFDP64WqqJ0b+3s2leReNq7ld70pVn1m8npyAZKvUc4/uo7WVLm0A1/U1f+iW9eqpYPKN/BY/+Ta2fp6ui0KUtha3B0xMICD66OLwrnmoFmxElEohL4OLZe7rnOW2G9M6Gej+LO5SeJip0YfiG+ImKQ1ngmGxpuopUOvcT1La/1TGki2gEV4AEm4QHW0fZ4Bjz0tdMVPGexUHQW/si9RWF8tJPsoykUcvS6slpbmil2ls9e7tcT6F4KZUCJv9nn6lWSf hdfs@hadoop'
        diff: (diff) -> # we dont need diff argument

  they.skip 'empty source on empty file', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      .on 'diff', (log) -> logs.push log.message
      @file
        target: "#{tmpdir}/file"
        content: ''
      @file
        target: "#{tmpdir}/file"
        content: ''
      @call ->
        logs.should.eql ['']

  they 'content on created file', ({ssh}) ->
    diff = null
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/file"
        content: 'some content'
        diff: (text, raw) -> diff = text
      , (err) ->
        diff.should.eql '1 + some content\n' unless err
