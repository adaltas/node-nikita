
nikita = require '../../src'
misc = require '../../src/misc'
crypto = require 'crypto'
test = require '../test'
they = require 'ssh2-they'

describe 'misc.file', ->

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

    they 'returns the directory md5', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/an_empty_dir"
      .file
        target: "#{scratch}/a_dir/a_file"
        content: 'hello'
      .call ({}, callback)->
        misc.file.hash ssh, "#{scratch}", (err, md5) ->
          md5.should.eql '5d41402abc4b2a76b9719d911017c592' unless err
          callback err
      .promise()

    they 'returns the directory md5 when empty', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: "#{scratch}/a_dir"
      .call ({}, callback)->
        misc.file.hash ssh, "#{scratch}/a_dir", (err, md5) ->
          md5.should.eql crypto.createHash('md5').update('').digest('hex') unless err
          callback err
      .promise()

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
