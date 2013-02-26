
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'

describe 'git', ->

  scratch = test.scratch @

  beforeEach (next) ->
    mecano.extract
      source: "#{__dirname}/../resources/repo.git.zip"
      destination: "#{scratch}"
    , next

  # it 'should init new repo over existing directory', (next) ->
  #   mecano.git
  #     source: "#{__dirname}/../resources/repo.git"
  #     destination: "#{scratch}"
  #   , (err, updated) ->
  #     updated.should.eql 1
  #     mecano.git
  #       source: "#{__dirname}/../resources/repo.git"
  #       destination: "#{scratch}"
  #     , (err, updated) ->
  #       updated.should.eql 0
  #       next()

  it 'should clone repo into new dir', (next) ->
    mecano.git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      return next err if err
      updated.should.eql 1
      mecano.git
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
      , (err, updated) ->
        updated.should.eql 0
        next()

  it 'should clone accross ssh', (next) ->
    mecano.git
      ssh: host: 'localhost'
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      return next err if err
      updated.should.eql 1
      mecano.git
        ssh: host: 'localhost'
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
      , (err, updated) ->
        updated.should.eql 0
        next()

  it 'should honore revision', (next) ->
    mecano.git
      source: "#{scratch}/repo.git"
      destination: "#{scratch}/my_repo"
    , (err, updated) ->
      return next err if err
      mecano.git
        source: "#{scratch}/repo.git"
        destination: "#{scratch}/my_repo"
        revision: 'v0.0.1'
      , (err, updated) ->
        updated.should.eql 1
        mecano.git
          source: "#{scratch}/repo.git"
          destination: "#{scratch}/my_repo"
          revision: 'v0.0.1'
        , (err, updated) ->
          updated.should.eql 0
          next()

