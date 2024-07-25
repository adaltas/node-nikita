
import session from '@nikitajs/core/session'
import test from '../test.coffee'

describe 'session.creation', ->
  return unless test.tags.api

  it 'handler is already registered, got function', ->
    session (->), (->)
    .should.be.rejectedWith
      code: 'NIKITA_SESSION_INVALID_ARGUMENTS'
      message: [
        'NIKITA_SESSION_INVALID_ARGUMENTS:'
        'handler is already registered, got function'
      ].join ' '

  it 'return from array no items', ->
    session []
    .should.finally.eql []

  it 'return from array with handlers', ->
    session [
      -> 1
      -> Promise.resolve 2
    ]
    .should.finally.eql [1, 2]

  it 'chain from array', ->
    stack = []
    await session [
      -> new Promise (resolve) ->
        setTimeout ->
          stack.push 1
          resolve()
        , 30
      -> new Promise (resolve) ->
        setTimeout ->
          stack.push 2
          resolve()
        , 20
    ]
    .call -> new Promise (resolve) ->
        setTimeout ->
          stack.push 3
          resolve()
        , 10
    stack.should.eql [1, 2, 3]
