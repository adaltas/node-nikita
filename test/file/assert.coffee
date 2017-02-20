
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file.assert', ->

  scratch = test.scratch @

  they 'file doesnt not exist', (ssh, next) ->
    mecano
    .file.assert "#{scratch}/a_file"
    .then (err) ->
      err.message.should.eql "File does not exists: \"#{scratch}/a_file\""
      next()

  they 'file exists', (ssh, next) ->
    mecano
    .file.touch "#{scratch}/a_file"
    .file.assert "#{scratch}/a_file"
    .then next

  they 'requires target', (ssh, next) ->
    mecano
    .file.assert
      content: "are u here"
    .then (err) ->
      err.message.should.eql 'Missing option: "target"'
      next()

  they 'content match', (ssh, next) ->
    mecano
    .file
      target: "#{scratch}/a_file"
      content: "are u here"
    .file.assert
      target: "#{scratch}/a_file"
      content: "are u here"
    .then next

  they 'option source is alias of target', (ssh, next) ->
    mecano
    .file
      target: "#{scratch}/a_file"
      content: "are u here"
    .file.assert
      source: "#{scratch}/a_file"
      content: "are u here"
    .then next

  they 'content dont match', (ssh, next) ->
    mecano
    .file
      target: "#{scratch}/a_file"
      content: "are u here"
    .file.assert
      target: "#{scratch}/a_file"
      content: "are u sure"
    .then (err) ->
      err.message.should.eql 'Invalid content match: expected "are u sure", got "are u here"'
      next()

  they 'send custom error message', (ssh, next) ->
    mecano
    .file
      target: "#{scratch}/a_file"
      content: "are u here"
    .file.assert
      target: "#{scratch}/a_file"
      content: "are u sure"
      error: 'Got it'
    .then (err) ->
      err.message.should.eql "Got it"
      next()
    
