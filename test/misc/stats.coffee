
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'misc.stats', ->

  scratch = test.scratch @

  they 'directory is true', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir "#{scratch}/a_dir"
    .fs.stat "#{scratch}/a_dir", (err, {stats}) ->
      misc.stats.isDirectory(stats.mode).should.be.true() unless err
    .promise()

  they 'directory is false', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .fs.stat "#{scratch}/a_file", (err, {stats}) ->
      misc.stats.isDirectory(stats.mode).should.be.false() unless err
    .promise()

  they 'file is true', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .fs.stat "#{scratch}/a_file", (err, {stats}) ->
      misc.stats.isFile(stats.mode).should.be.true() unless err
    .promise()

  they 'file is false', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir "#{scratch}/a_dir"
    .fs.stat "#{scratch}/a_dir", (err, {stats}) ->
      misc.stats.isFile(stats.mode).should.be.false() unless err
    .promise()
