
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'touch', ->

  scratch = test.scratch @
  
  they 'as a target option', (ssh, next) ->
    mecano.touch
      ssh: ssh
      target: "#{scratch}/a_file"
    , (err) ->
      return next err if err
      fs.readFile ssh, "#{scratch}/a_file", 'ascii', (err, content) ->
        return next err if err
        content.should.eql ''
        next()
      
  they 'as a string', (ssh, next) ->
    mecano.touch target: "#{scratch}/a_file" , (err) ->
      return next err if err
      fs.readFile ssh, "#{scratch}/a_file", 'ascii', (err, content) ->
        return next err if err
        content.should.eql ''
        next()

  they 'an existing file', (ssh, next) ->
    mecano
      ssh: ssh
    .touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.true()
    .touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.false()
    .then next
      
