import registry from '@nikitajs/core/registry'
import session from '@nikitajs/core/session'
import metadataRegister from '@nikitajs/core/plugins/metadata/register'
import utils from '@nikitajs/utils'
import test from '../../test.coffee'
# Note, register is imported on purpose
# When the test is executed along other tests,
# the global registry namespace is not filled with other registered actions
# For this reason, sessions are initialized with an empty registry
# `session($registry: registry.create())`
import '@nikitajs/core/register'

describe 'plugins.metadata.register', ->
  return unless test.tags.api

  it 'in session', ->
    session
      $registry: registry.create()
      $plugins: [
        metadataRegister
      ]
      $register:
        call: '@nikitajs/core/actions/call'
        test: (->)
    , ({registry}) -> registry.get flatten: true
    .then (actions) => actions.map (action) -> action.namespace
    .should.finally.eql [
      [ 'call' ], [ 'test' ]
    ]

  it 'in child action', ->
    session
      $registry: registry.create()
      $plugins: [
        metadataRegister
      ]
      $register:
        call: '@nikitajs/core/actions/call'
        test: (->)
    , ->
      @call ({registry}) -> registry.get flatten: true
    .then (actions) => actions.map (action) -> action.namespace
    .should.finally.eql [
      [ 'call' ], [ 'test' ]
    ]
