
import session from '@nikitajs/core/session'
import registry from '@nikitajs/core/registry'
import test from '../../test.coffee'
# Note, register is imported on purpose
# When the test is executed along other tests,
# the global registry namespace is not filled with other registered actions
# For this reason, sessions are initialized with an empty registry
# `session($registry: registry.create())`
import '@nikitajs/core/register'

describe 'session.action.registry', ->
  return unless test.tags.api

  it 'default to global registry', ->
    session ({registry}) ->
      registry.get flatten: true
    .should.finally.eql await registry.get flatten: true

  it 'short mode, pass custom registry', ->
    session
      $registry: registry.create()
    , ({registry}) ->
      registry.get flatten: true
    .should.finally.eql []
