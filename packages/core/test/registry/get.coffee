
{tags} = require '../test'
nikita = require '../../src'
registry = require '../../src/registry'
plugandplay = require 'plug-and-play'

describe 'registry.get', ->
  return unless tags.api

  it 'return null when not registered', ->
    reg = registry.create()
    action = await reg.get ['get', 'an', 'action']
    should(action).be.exactly(null)

  it 'a registered function', ->
    reg = await registry
    .create()
    .register ['get', 'an', 'action'], key: 'value', (->)
    {config} = await reg.get ['get', 'an', 'action']
    config.key.should.eql 'value'

  it 'get all', ->
    reg = registry.create()
    await reg.register ['get', 'first', 'action'], (->)
    await reg.register ['get', 'second', 'action'], (->)
    reg.get().then (actions) ->
      Object.keys(
        actions.get
      ).should.eql [ 'first', 'second' ]

  it 'option `deprecated`', ->
    reg = registry.create()
    reg.register ['new', 'function'], handler: (->)
    reg.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
    actions = await reg.get deprecate: false
    actions['new']['function'][''].handler.should.be.type 'function'
    (actions['old'] is undefined).should.be.true()
    actions = await reg.get deprecate: true
    actions['new']['function'][''].handler.should.be.type 'function'
    actions['old']['function'][''].handler.should.be.type 'function'

  it 'get all with flatten config', ->
    reg = registry.create()
    reg.register ['my', 'function'], handler: (->)
    actions = await reg.get flatten: true
    actions.some( (action) -> action.action.join('.') is 'my.function').should.be.true()

  it 'get all with flatten config and deprecate', ->
    reg = registry.create()
    reg.register ['new', 'function'], handler: (->)
    reg.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
    actions = await reg.get flatten: true, deprecate: false
    actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
    actions.some( (action) -> action.action.join('.') is 'old.function').should.be.false()
    actions = await reg.get flatten: true, deprecate: true
    actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
    actions.some( (action) -> action.action.join('.') is 'old.function').should.be.true()

  it 'return an immutable copy of the action', ->
    reg = registry.create
      plugins: plugandplay
        plugins: [
          ->
            hooks:
              'nikita:registry:normalize': (action) ->
                action.key = 'new value'
                action.new_key = 'new value'
        ]
    reg.register ['action'], key: 'value', handler: (->)
    action = await reg.get 'action'
    # Ensure the returned action is altered
    action.should.match
      config:
        key: 'new value', new_key: 'new value'
      handler: (val) -> val.should.be.a.Function()
    # Now, make sure the action is not altered
    action = await reg.get 'action', normalize: false
    action.should.match
      key: 'value'
      handler: (val) -> val.should.be.a.Function()
