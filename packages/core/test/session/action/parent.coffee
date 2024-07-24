
import session from '@nikitajs/core/session'
import test from '../../test.coffee'

describe 'session.action.parent', ->
  return unless test.tags.api

  it 'default to undefined', ->
    session ({parent}) ->
      parent
    .should.finally.eql undefined

  it 'initialized from parent', ->
    parent = await session key: 'value', (action) -> action
    await session
      $parent: parent
    , ({parent}) ->
      parent
    .should.finally.match config: key: 'value'
