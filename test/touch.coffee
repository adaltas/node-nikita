
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'touch', ->

  scratch = test.scratch @

  they 'an empty file', (ssh, next) ->
    mecano.touch
      ssh: ssh
      destination: "#{scratch}/a_file"
    , (err) ->
      return next err if err
      misc.file.readFile ssh, "#{scratch}/a_file", 'ascii', (err, content) ->
        return next err if err
        content.should.eql ''
        next()

