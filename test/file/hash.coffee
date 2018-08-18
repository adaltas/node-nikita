
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.hash', ->

  scratch = test.scratch @

  they 'from a file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'some content'
    .file.hash
      target: "#{scratch}/a_file"
    , (err, {status, hash}) ->
      status.should.be.true()
      hash.should.eql '9893532233caff98cd083a116b013c0b'
    .next (err, {status}) ->
      throw err if err
      status.should.be.true()
    .promise()

  they 'from a link', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'some content'
    .system.link
      source: "#{scratch}/a_file"
      target: "#{scratch}/a_link"
    .file.hash
      target: "#{scratch}/a_link"
    , (err, {status, hash}) ->
      status.should.be.true()
      hash.should.eql '9893532233caff98cd083a116b013c0b'
    .next (err, {status}) ->
      throw err if err
      status.should.be.true()
    .promise()

  they 'assert', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'some content'
    .file.hash
      target: "#{scratch}/a_file"
      hash: '9893532233caff98cd083a116b013c0b'
      relax: true
    , (err, {status}) ->
      status.should.be.true()
    .file.hash
      target: "#{scratch}/a_file"
      hash: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      relax: true
    , (err, {status}) ->
      err.message.should.eql 'Unexpected Hash, got "9893532233caff98cd083a116b013c0b" but exepected "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"'
      status.should.be.false()
    .promise()
