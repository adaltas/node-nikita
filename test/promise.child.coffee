
mecano = require '../src'
test = require './test'
fs = require 'fs'
domain = require 'domain'

describe 'promise child', ->

  scratch = test.scratch @

  describe 'child', ->

    it 'dont change', (next) ->
      touched = 0
      m = mecano
      .call (next) ->
        m
        .child()
        .touch
          destination: "#{scratch}/a_file"
        .then (err, changed) ->
          touched++
          changed.should.be.True
          next err
      .then (err, changed) ->
        changed.should.be.False
        touched.should.eql 1
        next()




