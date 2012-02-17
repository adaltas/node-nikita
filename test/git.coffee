
should = require 'should'
mecano = require '../'

describe 'git', ->

    # it 'should init new repo over existing directory', (next) ->
    #     mecano.git
    #         source: "#{__dirname}/../resources/repo.git"
    #         destination: "#{__dirname}"
    #     , (err, updated) ->
    #         updated.should.eql 1
    #         mecano.git
    #             source: "#{__dirname}/../resources/repo.git"
    #             destination: "#{__dirname}"
    #         , (err, updated) ->
    #             updated.should.eql 0
    #             mecano.rm "#{__dirname}/repo", next

    it 'should clone repo into new dir', (next) ->
        mecano.git
            source: "#{__dirname}/../resources/repo.git"
            destination: "#{__dirname}/my_repo"
        , (err, updated) ->
            should.not.exist err
            updated.should.eql 1
            mecano.git
                source: "#{__dirname}/../resources/repo.git"
                destination: "#{__dirname}/my_repo"
            , (err, updated) ->
                updated.should.eql 0
                mecano.rm "#{__dirname}/my_repo", next

    it 'should honore revision', (next) ->
        mecano.git
            source: "#{__dirname}/../resources/repo.git"
            destination: "#{__dirname}/my_repo"
        , (err, updated) ->
            should.not.exist err
            mecano.git
                source: "#{__dirname}/../resources/repo.git"
                destination: "#{__dirname}/my_repo"
                revision: 'v0.0.1'
            , (err, updated) ->
                updated.should.eql 1
                mecano.git
                    source: "#{__dirname}/../resources/repo.git"
                    destination: "#{__dirname}/my_repo"
                    revision: 'v0.0.1'
                , (err, updated) ->
                    updated.should.eql 0
                    mecano.rm "#{__dirname}/my_repo", next

