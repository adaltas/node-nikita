
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry.get', ->

  it 'return null when not registered', ->
    reg = registry.create()
    action = await reg.get ['get', 'an', 'action']
    should(action).be.exactly(null)

  it 'a registered function', ->
    reg = await registry
    .create()
    .register ['get', 'an', 'action'], key: 'value', (->)
    {options} = await reg.get ['get', 'an', 'action']
    options.key.should.eql 'value'

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

  it 'get all with flatten options', ->
    reg = registry.create()
    reg.register ['my', 'function'], handler: (->)
    actions = await reg.get flatten: true
    actions.some( (action) -> action.action.join('.') is 'my.function').should.be.true()

  it 'get all with flatten options and deprecate', ->
    reg = registry.create()
    reg.register ['new', 'function'], handler: (->)
    reg.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
    actions = await reg.get flatten: true, deprecate: false
    actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
    actions.some( (action) -> action.action.join('.') is 'old.function').should.be.false()
    actions = await reg.get flatten: true, deprecate: true
    actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
    actions.some( (action) -> action.action.join('.') is 'old.function').should.be.true()
