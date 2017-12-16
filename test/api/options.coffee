
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api options', ->

  it 'accept empty array [async]', ->
    nikita
    .call [], (options, callback) ->
      callback null, true
    .file []
    .next (err, status) ->
      status.should.be.false() unless err
    .promise()

  it 'accept empty array [sync]', ->
    nikita
    .call [], (options) ->
      return true
    .file []
    .next (err, status) ->
      status.should.be.false() unless err
    .promise()

  describe 'merging', ->

    it 'accept multiple options', ->
      nikita
      .call {a: 1, b: 0}, {b: 2, c: 3}, (options) ->
        options.should.containEql a: 1, b: 2, c: 3
      .promise()

    it 'is immutable', ->
      opts1 = {a: 1, b: 0}
      opts2 = {b: 2, c: 3}
      nikita
      .call opts1, opts2, (options) ->
        options.should.containEql a: 1, b: 2, c: 3
      , ->
        opts1.should.eql {a: 1, b: 0}
        opts2.should.eql {b: 2, c: 3}
      .promise()
