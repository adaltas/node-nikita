
should = require 'should'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'

describe 'misc', ->

  describe 'file', ->
    

    describe 'hash', ->

      it 'return the file md5', (next) ->
        misc.file.hash "#{__dirname}/../resources/render.eco", (err, md5) ->
          should.not.exist err
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
          next()

      it 'throw error if file does not exist', (next) ->
        misc.file.hash "#{__dirname}/does/not/exist", (err, md5) ->
          err.message.should.eql "Does not exist: #{__dirname}/does/not/exist"
          should.not.exist md5
          next()

      it 'throw error if file is a directory', (next) ->
        misc.file.hash "#{__dirname}", (err, md5) ->
          err.message.should.eql "Is a directory: #{__dirname}"
          should.not.exist md5
          next()

    describe 'compare', ->

      it '2 differents files', (next) ->
        file = "#{__dirname}/../resources/render.eco"
        misc.file.compare [file, file], (err, md5) ->
          should.not.exist err
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
          next()

      it 'throw error if there is a directory', (next) ->
        file = "#{__dirname}/../resources/render.eco"
        misc.file.compare [file, __dirname], (err, md5) ->
          err.message.should.eql "Is a directory: #{__dirname}"
          should.not.exist md5
          next()

