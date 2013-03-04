
crypto=require 'crypto'
should = require 'should'
mecano = require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
connect = require 'superexec/lib/connect'

describe 'misc', ->

  scratch = test.scratch @

  describe 'string', ->

    describe 'hash', ->

      it 'returns the string md5', ->
        md5 = misc.string.hash "hello"
        md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  describe 'file', ->

    describe 'exists', ->

      it 'check local filesystem', (next) ->
        misc.file.exists null, "#{__filename}", (err, exists) ->
          exists.should.be.ok
          misc.file.exists null, "#{__filename}/nothere", (err, exists) ->
            exists.should.not.be.ok
            next()

      it 'check over ssh', (next) ->
        connect host: 'localhost', (err, ssh) ->
          misc.file.exists ssh, "#{__filename}", (err, exists) ->
            exists.should.be.ok
            misc.file.exists ssh, "#{__filename}/nothere", (err, exists) ->
              exists.should.not.be.ok
              next()

    describe 'stat', ->

      it.skip 'check local file', (next) ->
        misc.file.stat null, __filename, (err, stat) ->
          return next err if err
          # console.log stat.isFile()
          next()

      it.skip 'check remote file', (next) ->
        connect host: 'localhost', (err, ssh) ->
          misc.file.stat ssh, __filename, (err, stat) ->
            return next err if err
            # console.log stat.isFile()
            next()

      it.skip 'check local directory', (next) ->
        misc.file.stat null, __dirname, (err, stat) ->
          return next err if err
          # console.log stat.isDirectory()
          next()

      it.skip 'check remote directory', (next) ->
        connect host: 'localhost', (err, ssh) ->
          misc.file.stat ssh, __dirname, (err, stat) ->
            return next err if err
            # console.log stat.isDirectory()
            next()

      it 'check local does not exists', (next) ->
        misc.file.stat null, "#{__dirname}/noone", (err, stat) ->
          err.code.should.eql 'ENOENT'
          next()

      it 'check remote does not exists', (next) ->
        connect host: 'localhost', (err, ssh) ->
          misc.file.stat ssh, "#{__dirname}/noone", (err, stat) ->
            err.code.should.eql 'ENOENT'
            next()

    describe 'hash', ->

      it 'returns the file md5', (next) ->
        misc.file.hash "#{__dirname}/../resources/render.eco", (err, md5) ->
          return next err if err
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
          next()

      it 'throws error if file does not exist', (next) ->
        misc.file.hash "#{__dirname}/does/not/exist", (err, md5) ->
          err.message.should.eql "Does not exist: #{__dirname}/does/not/exist"
          should.not.exist md5
          next()

      it 'returns the directory md5', (next) ->
        misc.file.hash "#{__dirname}/../resources", (err, md5) ->
          return next err if err
          md5.should.eql 'e667d74986ef3f22b7b6b7fc66d5ea59'
          next()

      it 'returns the directory md5 when empty', (next) ->
        mecano.mkdir "#{scratch}/a_dir", (err, created) ->
          return next err if err
          misc.file.hash "#{scratch}/a_dir", (err, md5) ->
            return next err if err
            md5.should.eql crypto.createHash('md5').update('').digest('hex')
            next()

    describe 'compare', ->

      it '2 differents files', (next) ->
        file = "#{__dirname}/../resources/render.eco"
        misc.file.compare [file, file], (err, md5) ->
          return next err if err
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
          next()

      # it 'throw error if there is a directory', (next) ->
      #   file = "#{__dirname}/../resources/render.eco"
      #   misc.file.compare [file, __dirname], (err, md5) ->
      #     err.message.should.eql "Is a directory: #{__dirname}"
      #     should.not.exist md5
      #     next()

