
crypto=require 'crypto'
should = require 'should'
mecano = require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'

describe 'misc', ->

  scratch = test.scratch @

  describe 'string', ->

    describe 'hash', ->

      it 'returns the string md5', ->
        md5 = misc.string.hash "hello", () ->
        md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  describe 'file', ->

    describe 'hash', ->

      it 'returns the file md5', (next) ->
        misc.file.hash "#{__dirname}/../resources/render.eco", (err, md5) ->
          should.not.exist err
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
          next()

      it 'throws error if file does not exist', (next) ->
        misc.file.hash "#{__dirname}/does/not/exist", (err, md5) ->
          err.message.should.eql "Does not exist: #{__dirname}/does/not/exist"
          should.not.exist md5
          next()

      it 'returns the directory md5', (next) ->
        misc.file.hash "#{__dirname}/../resources", (err, md5) ->
          should.not.exist err
          md5.should.eql 'e667d74986ef3f22b7b6b7fc66d5ea59'
          next()

      it 'returns the directory md5 when empty', (next) ->
        mecano.mkdir "#{scratch}/a_dir", (err, created) ->
          return next err if err
          misc.file.hash "#{scratch}/a_dir", (err, md5) ->
            should.not.exist err
            md5.should.eql crypto.createHash('md5').update('').digest('hex')
            next()

    describe 'compare', ->

      it '2 differents files', (next) ->
        file = "#{__dirname}/../resources/render.eco"
        misc.file.compare [file, file], (err, md5) ->
          should.not.exist err
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
          next()

      # it 'throw error if there is a directory', (next) ->
      #   file = "#{__dirname}/../resources/render.eco"
      #   misc.file.compare [file, __dirname], (err, md5) ->
      #     err.message.should.eql "Is a directory: #{__dirname}"
      #     should.not.exist md5
      #     next()

