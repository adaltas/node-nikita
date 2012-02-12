
assert = require 'assert'
fs = require 'fs'
path = require 'path'
mecano = require '../'

module.exports =

    # 'git # clone # destination exists': (next) ->
    #     mecano.git
    #         source: "#{__dirname}/../resources/repo.git"
    #         destination: "#{__dirname}"
    #     , (err, updated) ->
    #         assert.eql updated, 1
    #         mecano.git
    #             source: "#{__dirname}/../resources/repo.git"
    #             destination: "#{__dirname}"
    #         , (err, updated) ->
    #             assert.eql updated, 0
    #             mecano.rm "#{__dirname}/repo", next

    'git # clone': (next) ->
        mecano.git
            source: "#{__dirname}/../resources/repo.git"
            destination: "#{__dirname}/my_repo"
        , (err, updated) ->
            assert.ifError err
            assert.eql updated, 1
            mecano.git
                source: "#{__dirname}/../resources/repo.git"
                destination: "#{__dirname}/my_repo"
            , (err, updated) ->
                assert.eql updated, 0
                mecano.rm "#{__dirname}/my_repo", next

    'git # tag': (next) ->
        mecano.git
            source: "#{__dirname}/../resources/repo.git"
            destination: "#{__dirname}/my_repo"
        , (err, updated) ->
            assert.ifError err
            mecano.git
                source: "#{__dirname}/../resources/repo.git"
                destination: "#{__dirname}/repo"
                revision: 'v0.0.1'
            , (err, updated) ->
                assert.eql updated, 1
                mecano.git
                    source: "#{__dirname}/../resources/repo.git"
                    destination: "#{__dirname}/repo"
                    revision: 'v0.0.1'
                , (err, updated) ->
                    assert.eql updated, 0
                    mecano.rm "#{__dirname}/repo", next

