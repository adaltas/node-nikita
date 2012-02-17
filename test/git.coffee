
should = require 'should'
mecano = require '../'
test = require './test'

describe 'git', ->

    scratch = test.scratch @

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
        mecano.git
            source: "#{__dirname}/../resources/repo.git"
            destination: "#{scratch}/my_repo"
        , (err, updated) ->
            should.not.exist err
            updated.should.eql 1
            mecano.git
                source: "#{__dirname}/../resources/repo.git"
                destination: "#{scratch}/my_repo"
            , (err, updated) ->
                updated.should.eql 0
                next()

    it 'should honore revision', (next) ->
        mecano.git
            source: "#{__dirname}/../resources/repo.git"
            destination: "#{scratch}/my_repo"
        , (err, updated) ->
            should.not.exist err
            mecano.git
                source: "#{__dirname}/../resources/repo.git"
                destination: "#{scratch}/my_repo"
                revision: 'v0.0.1'
            , (err, updated) ->
                updated.should.eql 1
                mecano.git
                    source: "#{__dirname}/../resources/repo.git"
                    destination: "#{scratch}/my_repo"
                    revision: 'v0.0.1'
                , (err, updated) ->
                    updated.should.eql 0
                    next()

