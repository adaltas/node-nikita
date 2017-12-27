
nikita = require '../../src'
test = require '../test'

describe 'registry.get', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'get module', ->
      module = nikita.registry.get ['file', 'properties']
      module.handler.should.be.type 'function'

    it 'get unregistered module', ->
      module = nikita.registry.get ['does', 'not', 'exists']
      (module is null).should.be.true()

    it 'get all', ->
      modules = nikita.registry.get()
      modules.file.properties[''].handler.should.be.type 'function'

    it 'get all with deprecated', ->
      nikita.registry.register ['new', 'function'], handler: (->)
      nikita.registry.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      modules = nikita.registry.get deprecate: false
      modules['new']['function'][''].handler.should.be.type 'function'
      (modules['old'] is undefined).should.be.true()
      modules = nikita.registry.get deprecate: true
      modules['new']['function'][''].handler.should.be.type 'function'
      modules['old']['function'][''].handler.should.be.type 'function'
      nikita.registry.unregister ['new', 'function']
      nikita.registry.unregister ['old', 'function']

    it 'get all with flatten options', ->
      nikita.registry.register ['my', 'function'], handler: (->)
      modules = nikita.registry.get flatten: true
      modules['my.function'].handler.should.be.type 'function'
      nikita.registry.unregister ['my', 'function']

    it 'get all with flatten options and deprecate', ->
      nikita.registry.register ['new', 'function'], handler: (->)
      nikita.registry.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      modules = nikita.registry.get flatten: true, deprecate: false
      modules['new.function'].handler.should.be.type 'function'
      (modules['old.function'] is undefined).should.be.true()
      modules = nikita.registry.get flatten: true, deprecate: true
      modules['new.function'].handler.should.be.type 'function'
      modules['old.function'].handler.should.be.type 'function'
      nikita.registry.unregister ['new', 'function']
      nikita.registry.unregister ['old', 'function']
