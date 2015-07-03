
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'git', ->

  scratch = test.scratch @

  beforeEach (next) ->
    mecano.extract
      source: "#{__dirname}/../resources/repo.git.zip"
      destination: "#{scratch}"
    , next

  they 'clones repo into new dir', (ssh, next) ->
    mecano
      ssh: ssh
    .git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      updated.should.be.true()
    .git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      updated.should.be.false()
    .then next

  they 'honores revision', (ssh, next) ->
    mecano
      ssh: ssh
    .git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    .git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
      revision: 'v0.0.1'
    , (err, updated) ->
      updated.should.be.true()
    .git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
      revision: 'v0.0.1'
    , (err, updated) ->
      updated.should.be.false()
    .then next

  they 'preserves existing directory', (ssh, next) ->
    fs.mkdir null, "#{scratch}/my_repo", (err) ->
      return next err if err
      mecano.git
        ssh: ssh
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
      , (err, updated) ->
        err.message.should.eql 'Not a git repository'
        next()




