
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api child', ->

  scratch = test.scratch @

  it 'dont change status of parent context', (next) ->
    touched = 0
    m = mecano
    .call (options, next) ->
      m
      .child()
      .touch
        target: "#{scratch}/a_file"
      .then (err, changed) ->
        touched++
        changed.should.be.true()
        next err
    .then (err, changed) ->
      changed.should.be.false()
      touched.should.eql 1
      next()

  # it 'accept conditions', (next) ->
  #   touched = 0
  #   m = mecano
  #   .call (options, next) ->
  #     m
  #     .child()
  #     .touch
  #       target: "#{scratch}/a_file"
  #     .then (err, changed) ->
  #       touched++
  #       changed.should.be.true()
  #       next err
  #   .then (err, changed) ->
  #     changed.should.be.false()
  #     touched.should.eql 1
  #     next()
