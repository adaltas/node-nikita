
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-exec/lib/they'

describe 'git', ->

  scratch = test.scratch @

  beforeEach (next) ->
    mecano.extract
      source: "#{__dirname}/../resources/repo.git.zip"
      destination: "#{scratch}"
    , next

  they 'clones repo into new dir', (ssh, next) ->
    mecano.git
      ssh: ssh
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      return next err if err
      updated.should.eql 1
      mecano.git
        ssh: ssh
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
      , (err, updated) ->
        updated.should.eql 0
        next()

  they 'honores revision', (ssh, next) ->
    mecano.git
      ssh: ssh
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      return next err if err
      mecano.git
        ssh: ssh
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
        revision: 'v0.0.1'
      , (err, updated) ->
        updated.should.eql 1
        mecano.git
          ssh: ssh
          source: "#{scratch}/repo.git"
          destination: "#{scratch}/my_repo"
          revision: 'v0.0.1'
        , (err, updated) ->
          updated.should.eql 0
          next()

  they 'preserves existing directory', (ssh, next) ->
    misc.file.mkdir null, "#{scratch}/my_repo", (err) ->
      return next err if err
      mecano.git
        ssh: ssh
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
      , (err, updated) ->
        err.message.should.eql 'Not a git repository'
        next()




