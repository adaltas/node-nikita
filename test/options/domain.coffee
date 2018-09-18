
domain = require 'domain'
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "domain"', ->

  it 'uncatchable error in sync handler', ->
    nikita
      domain: true
    .call
      handler: ->
        setImmediate -> 
          throw Error 'Catch me'
    .call ->
      setImmediate ->
        next Error 'Shouldnt be called'
    .next (err, status) ->
      err.message.should.eql 'Invalid State Error [Catch me]'
    .promise()

  it 'catch thrown error in then', (next) ->
    # @see alternative test in "then.coffee"
    d = domain.create()
    d.on 'error', (err) ->
      err.message.should.eql 'Catchme'
      d.exit()
      next()
    nikita
      domain: d
    .next ->
      throw Error 'Catchme'
    null

  it 'catch thrown error when then not defined', (next) ->
    # @see alternative test in "then.coffee"
    d = domain.create()
    d.on 'error', (err) ->
      err.name.should.eql 'TypeError'
      d.exit()
      next()
    nikita
      domain: d
    .call ({}, callback) ->
      callback.property.does.not.exist
    .call ->
      next Error 'Shouldnt be called'
    null
