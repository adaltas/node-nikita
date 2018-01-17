
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.stat', ->

  scratch = test.scratch @

  they 'handle missing file', (ssh) ->
    nikita
      ssh: ssh
    .fs.stat
      target: "#{scratch}/not_here"
      relax: true
    , (err, stat) ->
      err.code.should.eql 'ENOENT'
    .promise()

  they 'with a file', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .fs.stat
      target: "#{scratch}/a_file"
    , (err, stat) ->
      return if err
      stat.isFile().should.be.true()
      stat.mode.should.be.a.Number()
      stat.uid.should.be.a.Number()
      stat.gid.should.be.a.Number()
      stat.size.should.be.a.Number()
      stat.atime.should.be.a.Number()
      stat.mtime.should.be.a.Number()
    .promise()

  they 'with a directory', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .fs.stat
      target: "#{scratch}/a_dir"
    , (err, stat) ->
      return if err
      stat.isDirectory().should.be.true()
    .promise()

  they 'with a file link', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_file"
    .fs.stat
      target: "#{scratch}/a_link"
    , (err, stat) ->
      return if err
      stat.isFile().should.be.true()
      stat.isSymbolicLink().should.be.false()
    .promise()

  they 'with a directory link', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_dir"
    .fs.stat
      target: "#{scratch}/a_link"
    , (err, stat) ->
      return if err
      stat.isDirectory().should.be.true()
      stat.isSymbolicLink().should.be.false()
    .promise()
