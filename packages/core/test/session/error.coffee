
import '@nikitajs/core/register'
import session from '@nikitajs/core/session'
import test from '../test.coffee'

describe 'session.error', ->
  return unless test.tags.api
  
  it 'error in last action but return valid result', ->
    session ->
      await @call (->)
      try
        await @call ->
          throw Error 'KO'
      'OK'
    .should.be.resolvedWith 'OK'
    
  it 'thrown error sync in last action', ->
    session ->
      await @call (->)
      await @call ->
        throw Error 'OK'
    .should.be.rejectedWith 'OK'
    
  it 'thrown error sync in first action', ->
    session name: 'parent', ->
      # Note, it is mandatory to wait for the promise completion
      # since we cant stop the execution flow if an action failed.
      await @call ->
        throw Error 'OK'
      await @call ->
        throw Error 'KO'
    .should.be.rejectedWith 'OK'
      
  it 'thrown error async in last action', ->
    session ->
      await @call (->)
      await @call ->
        new Promise (resolve, reject) ->
          setImmediate -> reject Error 'OK'
    .should.be.rejectedWith 'OK'
      
  it 'thrown error async in first action', ->
    session ->
      await @call ->
        new Promise (resolve, reject) ->
          setImmediate -> reject Error 'OK'
      await @call ->
        throw Error 'KO'
    .should.be.rejectedWith 'OK'
