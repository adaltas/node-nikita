
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
crypto = require 'crypto'

describe 'file.hash', ->

  scratch = test.scratch @

  they 'from a file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'some content'
      shy: true
    .file.hash
      target: "#{scratch}/a_file"
    , (err, {status, hash}) ->
      status.should.be.true() unless err
      hash.should.eql '9893532233caff98cd083a116b013c0b' unless err
    .next (err, {status}) ->
      throw err if err
      status.should.be.false()
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
      status.should.be.true() unless err
      hash.should.eql '9893532233caff98cd083a116b013c0b' unless err
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
      status.should.be.true() unless err
    .file.hash
      target: "#{scratch}/a_file"
      hash: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      relax: true
    , (err, {status}) ->
      err.message.should.eql 'Unexpected Hash, got "9893532233caff98cd083a116b013c0b" but exepected "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"' unless err
      status.should.be.false() unless err
    .promise()

  they 'throws error if file does not exist', (ssh) ->
    nikita
      ssh: ssh
    .file.hash
      target: "#{__dirname}/does/not/exist"
      relax: true
    , (err, {status}) ->
      err.message.should.eql "Missing File: no file exists for target \"#{__dirname}/does/not/exist\""
    .promise()

  they 'returns the file md5 if globbing match only one file', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/an_empty_dir"
    .file
      target: "#{scratch}/a_dir/a_file"
      content: 'some content'
    .file.hash "#{scratch}", (err, {hash}) ->
      hash.should.eql '9893532233caff98cd083a116b013c0b' unless err
    .promise()

  they 'returns the directory md5', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/an_empty_dir"
    .file
      target: "#{scratch}/a_dir/file_1"
      content: 'hello 1'
    .file
      target: "#{scratch}/a_dir/file_2"
      content: 'hello 2'
    .file.hash "#{scratch}", (err, {hash}) ->
      hash.should.eql 'df940215c7446254f1334d923b3053c6' unless err
    .promise()

  they 'returns the directory md5 when empty', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .file.hash  "#{scratch}/a_dir", (err, {hash}) ->
      hash.should.eql crypto.createHash('md5').update('').digest('hex') unless err
    .promise()
