
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "relax"', ->

  it.skip 'sync', ->
    nikita
    .call relax: true, ->
      throw Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call -> # with parent
      @call relax: true, (_, callback) ->
        callback Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont cry, laugh outloud'
    .call ({}, callback) ->
      callback null, true
    .next (err, {status}) ->
      (err is undefined).should.be.true()
      status.should.be.true() unless err

  it.skip 'sync with error throw in child', ->
    nikita
    .call relax: true, ->
      @call ->
        throw Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call relax: true, ->
      @call (_, callback)->
        callback Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call -> # with parent
      @call relax: true, ->
        @call ->
          throw Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont cry, laugh outloud'
    .call -> # with parent
      @call relax: true, ->
        @call (_, callback) ->
          callback Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont cry, laugh outloud'
    .call ({}, callback) ->
      callback null, true
    .next (err, {status}) ->
      (err is undefined).should.be.true()
      status.should.be.true() unless err
    .promise()
  
  it.skip 'thrown error in callback are handled as an error', ->
    nikita
    .call
      relax: true
    , (->), ->
      throw Error 'Catch me'
    .next (err) ->
      err.message.should.eql 'Catch me'
    .promise()
  
  it.skip 'thrown error in callback are followed to parent sync call', ->
    nikita
    .call level: 'parent', ->
      @call
        level: 'child'
        relax: true
      ,(->), ->
        throw Error 'Catch me'
    .next (err) ->
      err.message.should.eql 'Catch me'
    .promise()

  it.skip 'async', ->
    nikita
    .call relax: true, ({}, callback) ->
      setImmediate ->
        callback Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call ({}, callback) ->
      callback null, true
    .next (err, {status}) ->
      (err is undefined).should.be.true()
      status.should.be.true() unless err
    .promise()
