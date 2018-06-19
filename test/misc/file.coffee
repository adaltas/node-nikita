
nikita = require '../../src'
misc = require '../../src/misc'
crypto = require 'crypto'
test = require '../test'
they = require 'ssh2-they'

describe 'file', ->

  scratch = test.scratch @

  describe 'hash', ->

    they 'returns the file md5', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'Hello'
      .call (_, callback) ->
        misc.file.hash ssh, "#{scratch}/a_file", (err, md5) ->
          md5.should.eql '8b1a9953c4611296a827abf8c47804d7' unless err
          callback err
      .promise()

    they 'throws error if file does not exist', (ssh, next) ->
      misc.file.hash ssh, "#{__dirname}/does/not/exist", (err, md5) ->
        err.message.should.eql "Does not exist: #{__dirname}/does/not/exist"
        should.not.exist md5
        next()

    they 'returns the directory md5', (ssh, next) ->
      misc.file.hash ssh, "#{__dirname}/../resources", (err, md5) ->
        return next err if err
        md5.should.eql 'fecbff1eff387b8059e08130dfda56cf'
        next()

    they 'returns the directory md5 when empty', (ssh, next) ->
      nikita.system.mkdir "#{scratch}/a_dir", (err, created) ->
        return next err if err
        misc.file.hash ssh, "#{scratch}/a_dir", (err, md5) ->
          return next err if err
          md5.should.eql crypto.createHash('md5').update('').digest('hex')
          next()

  describe 'compare', ->

    they '2 differents files', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/a_file"
        content: 'Hello'
      .call (_, callback) ->
        misc.file.compare ssh, ["#{scratch}/a_file", "#{scratch}/a_file"], (err, md5) ->
          md5.should.eql '8b1a9953c4611296a827abf8c47804d7' unless err
          callback err
      .promise()
