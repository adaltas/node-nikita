
nikita = require '../../src'

describe 'registry.get', ->

  describe 'global', ->

    it 'get module', ->
      module = nikita.registry.get ['file', 'properties']
      module.handler.should.be.type 'function'

    it.skip 'get unregistered module', ->
      module = nikita.registry.get ['does', 'not', 'exists']
      (module is null).should.be.true()

    it.skip 'get all', ->
      actions = nikita.registry.get()
      actions.file.properties[''].handler.should.be.type 'function'

    it.skip 'get all with deprecated', ->
      nikita.registry.register ['new', 'function'], handler: (->)
      nikita.registry.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      actions = nikita.registry.get deprecate: false
      actions['new']['function'][''].handler.should.be.type 'function'
      (actions['old'] is undefined).should.be.true()
      actions = nikita.registry.get deprecate: true
      actions['new']['function'][''].handler.should.be.type 'function'
      actions['old']['function'][''].handler.should.be.type 'function'
      nikita.registry.unregister ['new', 'function']
      nikita.registry.unregister ['old', 'function']

    it 'get all with flatten options', ->
      nikita.registry.register ['my', 'function'], handler: (->)
      actions = nikita.registry.get flatten: true
      actions.some( (action) -> action.action.join('.') is 'my.function').should.be.true()
      nikita.registry.unregister ['my', 'function']

    it.skip 'get all with flatten options and deprecate', ->
      nikita.registry.register ['new', 'function'], handler: (->)
      nikita.registry.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      actions = nikita.registry.get flatten: true, deprecate: false
      actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
      actions.some( (action) -> action.action.join('.') is 'old.function').should.be.false()
      actions = nikita.registry.get flatten: true, deprecate: true
      actions.some( (action) -> action.action.join('.') is 'new.function').should.be.true()
      actions.some( (action) -> action.action.join('.') is 'old.function').should.be.true()
      nikita.registry.unregister ['new', 'function']
      nikita.registry.unregister ['old', 'function']
