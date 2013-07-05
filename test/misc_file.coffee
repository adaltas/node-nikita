
crypto=require 'crypto'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'misc.file', ->

  scratch = test.scratch @

  describe 'chmod', ->

    they 'change permission', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/a_file", "hello", (err) ->
        misc.file.chmod ssh, "#{scratch}/a_file", '546', (err) ->
          return next err if err
          misc.file.stat ssh, "#{scratch}/a_file", (err, stat) ->
            "0o0#{(stat.mode & 0o0777).toString 8}".should.eql '0o0546'
            next err

  describe 'write', ->

    they 'append', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/a_file", "hello", flags: 'a', (err) ->
        return next err if err
        misc.file.writeFile ssh, "#{scratch}/a_file", "world", flags: 'a', (err) ->
          return next err if err
          misc.file.readFile ssh, "#{scratch}/a_file", 'utf8', (err, content) ->
            content.should.eql "helloworld"
            next()

  describe 'rename', ->

    they 'work', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/a_file", "helloworld", flags: 'a', (err) ->
        return next err if err
        misc.file.rename ssh, "#{scratch}/a_file", "#{scratch}/a_renamed_file", (err) ->
          return next err if err
          misc.file.readFile ssh, "#{scratch}/a_renamed_file", 'utf8', (err, content) ->
            return next err if err
            content.should.eql "helloworld"
            next()

  describe 'readFile', ->

    they 'throw error if not exists', (ssh, next) ->
      misc.file.readFile ssh, "#{__dirname}/doesnotexist", 'utf8', (err, exists) ->
        err.message.should.eql "ENOENT, open '#{__dirname}/doesnotexist'"
        err.errno.should.eql 34
        err.code.should.eql 'ENOENT'
        err.path.should.eql "#{__dirname}/doesnotexist"
        next()

  describe 'exists', ->

    they 'on file', (ssh, next) ->
      misc.file.exists ssh, "#{__filename}", (err, exists) ->
        exists.should.be.ok
        next()

    they 'does not exist', (ssh, next) ->
      misc.file.exists ssh, "#{__filename}/nothere", (err, exists) ->
        exists.should.not.be.ok
        next()

  describe 'stat', ->

    they 'on file', (ssh, next) ->
      misc.file.stat ssh, __filename, (err, stat) ->
        return next err if err
        stat.isFile().should.be.ok
        next()

    they 'on directory', (ssh, next) ->
      misc.file.stat ssh, __dirname, (err, stat) ->
        return next err if err
        stat.isDirectory().should.be.ok
        next()

    they 'check does not exist', (ssh, next) ->
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

  describe 'remove', ->

    they 'a dir', (ssh, next) ->
      mecano.mkdir
        ssh: ssh
        destination: "#{scratch}/remove_dir"
      , (err, created) ->
        return next err if err
        misc.file.remove ssh, "#{scratch}/remove_dir", (err) ->
          return next err if err
          misc.file.exists ssh, "#{scratch}/remove_dir", (err, exists) ->
            return next err if err
            exists.should.not.be.ok
            next()

    they 'handle a missing remote dir', (ssh, next) ->
      misc.file.remove ssh, "#{scratch}/remove_missing_dir", (err) ->
        misc.file.exists ssh, "#{scratch}/remove_missing_dir", (err, exists) ->
          return next err if err
          exists.should.not.be.ok
          next()
