
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov' else require '../lib'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-they'

describe 'chmod', ->

  scratch = test.scratch @

  they 'change a permission of a file', (ssh, next) ->
    mecano.touch
      ssh: ssh
      destination: "#{scratch}/a_file"
      mode: 0o754
    , (err) ->
      return next err if err
      mecano.chmod
        ssh: ssh
        destination: "#{scratch}/a_file"
        mode: 0o744
      , (err, modified) ->
        return next err if err
        modified.should.eql 1
        mecano.chmod
          ssh: ssh
          destination: "#{scratch}/a_file"
          mode: 0o744
        , (err, modified) ->
          return next err if err
          modified.should.eql 0
          next()

