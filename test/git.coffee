
should = require 'should'
mecano = require '../'
test = require './test'

describe 'git', ->

    scratch = test.scratch @

    beforeEach (next) ->
        mecano.extract
            source: "#{__dirname}/../resources/repo.git.zip"
            destination: "#{scratch}"
        , next

    # it 'should init new repo over existing directory', (next) ->
    #     mecano.git
    #         source: "#{__dirname}/../resources/repo.git"
    #         destination: "#{scratch}"
    #     , (err, updated) ->
    #         updated.should.eql 1
    #         mecano.git
    #             source: "#{__dirname}/../resources/repo.git"
    #             destination: "#{scratch}"
    #         , (err, updated) ->
    #             updated.should.eql 0
    #             next()

    it 'should clone repo into new dir', (next) ->
        await mecano.git
            source: "#{scratch}/repo.git"
            destination: "#{scratch}/my_repo"
        , defer err, updated
        should.not.exist err
        updated.should.eql 1
        await mecano.git
            source: "#{scratch}/repo.git"
            destination: "#{scratch}/my_repo"
        , defer err, updated
        updated.should.eql 0
        next()

    it 'should honore revision', (next) ->
        await mecano.git
            source: "#{scratch}/repo.git"
            destination: "#{scratch}/my_repo"
        , defer err, updated
        should.not.exist err
        await mecano.git
            source: "#{scratch}/repo.git"
            destination: "#{scratch}/my_repo"
            revision: 'v0.0.1'
        , defer err, updated
        updated.should.eql 1
        await mecano.git
            source: "#{scratch}/repo.git"
            destination: "#{scratch}/my_repo"
            revision: 'v0.0.1'
        , defer err, updated
        updated.should.eql 0
        next()

