
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'

describe 'remove', ->

  scratch = test.scratch @

  it 'should delete a file', (next) ->
    mecano.copy
      source: "#{__dirname}/../resources/a_dir/a_file"
      destination: "#{scratch}/a_file"
    , (err, copied) ->
      mecano.remove
        source: "#{scratch}/a_file"
      , (err, removed) ->
        should.not.exist err
        removed.should.eql 1
        next()


