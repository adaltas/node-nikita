
mecano = require '../src'
test = require './test'
fs = require 'fs'
domain = require 'domain'

describe 'promise child', ->

  scratch = test.scratch @

  describe 'child', ->

    it 'dont change status of parent context', (next) ->
      touched = 0
      m = mecano
      .call (options, next) ->
        m
        .child()
        .touch
          destination: "#{scratch}/a_file"
        .then (err, changed) ->
          touched++
          changed.should.be.true
          next err
      .then (err, changed) ->
        changed.should.be.false
        touched.should.eql 1
        next()

    # it 'accept conditions', (next) ->
    #   touched = 0
    #   m = mecano
    #   .call (options, next) ->
    #     m
    #     .child()
    #     .touch
    #       destination: "#{scratch}/a_file"
    #     .then (err, changed) ->
    #       touched++
    #       changed.should.be.True
    #       next err
    #   .then (err, changed) ->
    #     changed.should.be.False
    #     touched.should.eql 1
    #     next()




