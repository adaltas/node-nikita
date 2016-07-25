
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'write assert', ->

  scratch = test.scratch @

  they 'requires content', (ssh, next) ->
    mecano
    .write.assert
      target: "#{scratch}/a_file"
    .then (err) ->
      err.message.should.eql "Required option 'content'"
      next()

  they 'requires target', (ssh, next) ->
    mecano
    .write.assert
      content: "are u here"
    .then (err) ->
      err.message.should.eql "Required option 'target'"
      next()

  they 'content match', (ssh, next) ->
    mecano
    .write
      target: "#{scratch}/a_file"
      content: "are u here"
    .write.assert
      target: "#{scratch}/a_file"
      content: "are u here"
    .then next

  they 'content dont match', (ssh, next) ->
    mecano
    .write
      target: "#{scratch}/a_file"
      content: "are u here"
    .write.assert
      target: "#{scratch}/a_file"
      content: "are u sure"
    .then (err) ->
      err.message.should.eql "Invalid content match"
      next()

  they 'send custom error message', (ssh, next) ->
    mecano
    .write
      target: "#{scratch}/a_file"
      content: "are u here"
    .write.assert
      target: "#{scratch}/a_file"
      content: "are u sure"
      error: 'Got it'
    .then (err) ->
      err.message.should.eql "Got it"
      next()
    
