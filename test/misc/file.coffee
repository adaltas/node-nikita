
mecano = require '../../src'
misc = require '../../src/misc'
should = require 'should'
crypto = require 'crypto'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file', ->

  scratch = test.scratch @

  describe 'hash', ->

    they 'returns the file md5', (ssh, next) ->
      misc.file.hash ssh, "#{__dirname}/../resources/render.eco", (err, md5) ->
        return next err if err
        md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
        next()

    they 'throws error if file does not exist', (ssh, next) ->
      misc.file.hash ssh, "#{__dirname}/does/not/exist", (err, md5) ->
        err.message.should.eql "Does not exist: #{__dirname}/does/not/exist"
        should.not.exist md5
        next()

    they 'returns the directory md5', (ssh, next) ->
      misc.file.hash ssh, "#{__dirname}/../resources", (err, md5) ->
        return next err if err
        md5.should.eql '97e14a5b2eb1a66263e4c3830628c89f'
        next()

    they 'returns the directory md5 when empty', (ssh, next) ->
      mecano.system.mkdir "#{scratch}/a_dir", (err, created) ->
        return next err if err
        misc.file.hash ssh, "#{scratch}/a_dir", (err, md5) ->
          return next err if err
          md5.should.eql crypto.createHash('md5').update('').digest('hex')
          next()

  describe 'compare', ->

    they '2 differents files', (ssh, next) ->
      file = "#{__dirname}/../resources/render.eco"
      misc.file.compare ssh, [file, file], (err, md5) ->
        return next err if err
        md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'
        next()

    # they 'throw error if there is a directory', (ssh, next) ->
    #   file = "#{__dirname}/../resources/render.eco"
    #   misc.file.compare ssh, [file, __dirname], (err, md5) ->
    #     err.message.should.eql "Is a directory: #{__dirname}"
    #     should.not.exist md5
    #     next()

  describe 'remove', ->

    they 'a dir', (ssh, next) ->
      mecano.system.mkdir
        ssh: ssh
        target: "#{scratch}/remove_dir"
      , (err, created) ->
        return next err if err
        misc.file.remove ssh, "#{scratch}/remove_dir", (err) ->
          return next err if err
          fs.exists ssh, "#{scratch}/remove_dir", (err, exists) ->
            return next err if err
            exists.should.be.false()
            next()

    they 'handle a missing remote dir', (ssh, next) ->
      misc.file.remove ssh, "#{scratch}/remove_missing_dir", (err) ->
        fs.exists ssh, "#{scratch}/remove_missing_dir", (err, exists) ->
          return next err if err
          exists.should.be.false()
          next()
