
import nikita from '@nikitajs/core'
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

  it 'argument cannot be an array, got []', ->
    session []
    .should.be.rejectedWith
      code: 'NIKITA_SESSION_INVALID_ARGUMENTS'
      message: [
        'NIKITA_SESSION_INVALID_ARGUMENTS:'
        'argument cannot be an array, got []'
      ].join ' '

  it 'argument cannot be an array, got [function,function]', ->
    session [
      -> new Promise (resolve) ->
        setTimeout ->
          resolve 1
        , 100
      -> new Promise (resolve) ->
        setTimeout ->
          resolve 2
        , 10
    ]
    .should.be.rejectedWith
      code: 'NIKITA_SESSION_INVALID_ARGUMENTS'
      message: [
        'NIKITA_SESSION_INVALID_ARGUMENTS:'
        'argument cannot be an array, got [function,function]'
      ].join ' '
