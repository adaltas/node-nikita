
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api child', ->

  scratch = test.scratch @

  it 'dont change status of parent action', ->
    touched = 0
    n = nikita()
    n.call ({}, next) ->
      n
      .child()
      .file.touch
        target: "#{scratch}/a_file"
      .next (err, {status}) ->
        touched++
        status.should.be.true()
        next err
    .next (err, {status}) ->
      status.should.be.false()
      touched.should.eql 1
    .promise()

  # it 'accept conditions', (next) ->
  #   touched = 0
  #   m = nikita
  #   .call ({}, next) ->
  #     m
  #     .child()
  #     .file.touch
  #       target: "#{scratch}/a_file"
  #     .next (err, changed) ->
  #       touched++
  #       changed.should.be.true()
  #       next err
  #   .next (err, changed) ->
  #     changed.should.be.false()
  #     touched.should.eql 1
  #     next()
