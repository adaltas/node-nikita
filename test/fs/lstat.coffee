
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.lstat', ->

  scratch = test.scratch @

  they 'with a file link', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'hello'
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_file"
    .fs.lstat
      target: "#{scratch}/a_link"
    , (err, stat) ->
      return if err
      stat.isFile().should.be.false()
      stat.isSymbolicLink().should.be.true()
    .promise()

  they 'with a directory link', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/a_dir"
    .system.link
      target: "#{scratch}/a_link"
      source: "#{scratch}/a_dir"
    .fs.lstat
      target: "#{scratch}/a_link"
    , (err, stat) ->
      return if err
      stat.isDirectory().should.be.false()
      stat.isSymbolicLink().should.be.true()
    .promise()
