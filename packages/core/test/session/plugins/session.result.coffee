
import nikita from '@nikitajs/core'
import session from '@nikitajs/core/session'
import history from '@nikitajs/core/plugins/history'
import position from '@nikitajs/core/plugins/metadata/position'
import test from '../../test.coffee'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.result', ->
  return unless test.tags.api

  it 'called from root session', ->
    called = false
    await session $plugins: [
      ->
        hooks: 'nikita:result': ({action}, handler) ->
          await new Promise (resolved) ->
            called = true
            setImmediate resolved
          handler
    ], (->)
    called.should.be.true()

  it 'called before action and children resolved', ->
    stack = []
    await session $plugins: [
      history
      position
      ->
        hooks: 'nikita:result': ({action}, handler) ->
          await new Promise (resolved) ->
            stack.push 'session:result:'+action.metadata.position.join(',')
            setImmediate resolved
          handler
    ], ->
      stack.push 'parent:handler:start'
      await @call ->
        new Promise (resolve) -> setImmediate ->
          stack.push 'child:1'
          resolve()
      await @call ->
        stack.push 'child:2'
      stack.push 'parent:handler:end'
      null
    stack.should.eql [
      'parent:handler:start'
      'child:1'
      'session:result:0,0'
      'child:2'
      'session:result:0,1'
      'parent:handler:end'
      'session:result:0'
    ]
