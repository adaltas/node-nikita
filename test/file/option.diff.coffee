
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file options diff', ->

  scratch = test.scratch @

  they 'type is a function', (ssh, next) ->
    diffcalled = false
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/file"
      content: 'Testing diff\noriginal text'
    .file
      target: "#{scratch}/file"
      content: 'Testing diff\nnew text'
      diff: (text, diff) ->
        diffcalled = true
        diff.should.eql [
          { value: 'Testing diff\n', count: 1 }
          { value: 'original text', count: 1, added: undefined, removed: true }
          { value: 'new text', count: 1, added: true, removed: undefined }
        ]
    .then (err) ->
      diffcalled.should.be.true() unless err
      next err

  they 'emit logs', (ssh, next) ->
    # Prepare by creating a file with content
    logs = []
    mecano
      ssh: ssh
    .on 'diff', (log) -> logs.push log.message
    .file
      target: "#{scratch}/file"
      content: 'Testing diff\noriginal text'
    .file
      target: "#{scratch}/file"
      content: 'Testing diff\nnew text'
    .then (err) ->
      logs.should.eql [
        '1 + Testing diff\n2 + original text\n'
        '2 - original text\n2 + new text\n'
      ] unless err
      next err

  they 'write a buffer', (ssh, next) ->
    # Passing a buffer as content resulted to a diff error 
    # with message "#{content} has no method 'split'",
    # make sure this is fixed for ever
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/file"
      content: new Buffer 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMKgZ7/2BG9T0vCJT8qlaH1KJNLSqEiJDHZMirPdzVsbI8x1AiT0EO5D47aROAKXTimVY3YsFr2ETXbLxjFFDP64WqqJ0b+3s2leReNq7ld70pVn1m8npyAZKvUc4/uo7WVLm0A1/U1f+iW9eqpYPKN/BY/+Ta2fp6ui0KUtha3B0xMICD66OLwrnmoFmxElEohL4OLZe7rnOW2G9M6Gej+LO5SeJip0YfiG+ImKQ1ngmGxpuopUOvcT1La/1TGki2gEV4AEm4QHW0fZ4Bjz0tdMVPGexUHQW/si9RWF8tJPsoykUcvS6slpbmil2ls9e7tcT6F4KZUCJv9nn6lWSf hdfs@hadoop'
      diff: (diff) -> # we dont need diff argument
    .then next

  they 'empty source on empty file', (ssh, next) ->
    logs = []
    mecano
      ssh: ssh
    .on 'diff', (log) -> logs.push log.message
    .file
      target: "#{scratch}/file"
      content: ''
    .file
      target: "#{scratch}/file"
      content: ''
    .then (err) ->
      logs.should.eql [''] unless err
      next err

  they 'content on created file', (ssh, next) ->
    diff = null
    mecano.file
      ssh: ssh
      target: "#{scratch}/file"
      content: 'some content'
      diff: (text, raw) -> diff = text
    , (err) ->
      diff.should.eql '1 + some content\n' unless err
      next err
