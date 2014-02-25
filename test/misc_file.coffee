
path = require 'path'
crypto = require 'crypto'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'misc.file', ->

  scratch = test.scratch @

  describe 'createReadStream', ->

    they 'pass error if file does not exists', (ssh, next) ->
      misc.file.createReadStream ssh, "#{scratch}/not_here", (err, stream) ->
        stream.on 'error', (err) ->
          err.message.should.eql "ENOENT, open '#{scratch}/not_here'"
          err.errno.should.eql 34
          err.code.should.eql 'ENOENT'
          err.path.should.eql '/tmp/mecano-test/not_here'
          next()

    they 'pass error if file is a directory', (ssh, next) ->
      misc.file.createReadStream ssh, __dirname, (err, stream) ->
        stream.on 'error', (err) ->
          err.message.should.eql "EISDIR, read"
          err.errno.should.eql 28
          err.code.should.eql 'EISDIR'
          next()

  describe 'chmod', ->

    they 'change permission', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/a_file", "hello", (err) ->
        misc.file.chmod ssh, "#{scratch}/a_file", '546', (err) ->
          return next err if err
          misc.file.stat ssh, "#{scratch}/a_file", (err, stat) ->
            "0o0#{(stat.mode & 0o0777).toString 8}".should.eql '0o0546'
            next err

  describe 'cmpmod', ->

    it 'compare strings of same size', ->
      misc.file.cmpmod('544', '544').should.be.ok
      misc.file.cmpmod('544', '322').should.not.be.ok

    it 'compare strings of different sizes', ->
      misc.file.cmpmod('544', '4544').should.be.ok
      misc.file.cmpmod('544', '4543').should.not.be.ok
      misc.file.cmpmod('0322', '322').should.be.ok
      misc.file.cmpmod('0544', '322').should.not.be.ok

    it 'compare int with string', ->
      misc.file.cmpmod(0o0744, '744').should.be.ok
      misc.file.cmpmod(0o0744, '0744').should.be.ok

    it 'compare int with string', ->
      misc.file.cmpmod('744', 0o0744).should.be.ok
      misc.file.cmpmod('0744', 0o0744).should.be.ok


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

  describe 'readdir', ->
    they 'list', (ssh, next) ->
      misc.file.readdir ssh, "#{__dirname}", (err, files) ->
        return next err if err
        files.length.should.be.above 10
        files.indexOf(path.basename __filename).should.not.equal -1
        next()

  describe 'readFile', ->

    they 'pass error to callback if not exists', (ssh, next) ->
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

  describe 'mkdir', ->

    they 'create a new directory', (ssh, next) ->
      misc.file.mkdir ssh, "#{scratch}/new_dir", (err) ->
        next err

    they 'pass error if dir exists', (ssh, next) ->
      misc.file.mkdir ssh, "#{scratch}/new_dir", (err) ->
        misc.file.mkdir ssh, "#{scratch}/new_dir", (err) ->
          err.message.should.eql "EEXIST, mkdir '#{scratch}/new_dir'"
          err.path.should.eql "#{scratch}/new_dir"
          err.errno.should.eql 47
          err.code.should.eql 'EEXIST'
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
        md5.should.eql 'e667d74986ef3f22b7b6b7fc66d5ea59'
        next()

    they 'returns the directory md5 when empty', (ssh, next) ->
      mecano.mkdir "#{scratch}/a_dir", (err, created) ->
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
