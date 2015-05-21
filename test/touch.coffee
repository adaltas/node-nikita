
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'touch', ->

  scratch = test.scratch @

  they 'an empty file', (ssh, next) ->
    mecano.touch
      ssh: ssh
      destination: "#{scratch}/a_file"
    , (err) ->
      return next err if err
      fs.readFile ssh, "#{scratch}/a_file", 'ascii', (err, content) ->
        return next err if err
        content.should.eql ''
        next()

  they 'an existing file', (ssh, next) ->
    mecano
      ssh: ssh
    .touch
      destination: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.ok
    .touch
      destination: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.not.be.ok
    .then next
      

