
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'git', ->

  scratch = test.scratch @

  beforeEach (next) ->
    mecano
    .tools.extract
      source: "#{__dirname}/../resources/repo.git.zip"
      target: "#{scratch}"
    .then next

  they 'clones repo into new dir', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
    , (err, updated) ->
      updated.should.be.true()
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
    , (err, updated) ->
      updated.should.be.false()
    .then next

  they 'honores revision', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
      revision: 'v0.0.1'
    , (err, updated) ->
      updated.should.be.true()
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
      revision: 'v0.0.1'
    , (err, updated) ->
      updated.should.be.false()
    .then next

  they 'preserves existing directory', (ssh, next) ->
    mecano
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/my_repo"
    .tools.git
      source: "#{scratch}/repo.git"
      target: "#{scratch}/my_repo"
      relax: true
    , (err, updated) ->
      err.message.should.eql 'Not a git repository'
    .then next
