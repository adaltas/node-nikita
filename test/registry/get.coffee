
nikita = require '../../src'
test = require '../test'

describe 'registry.get', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'get module', ->
      module = nikita.get ['file', 'properties']
      module.handler.should.be.type 'function'

    it 'get unregistered module', ->
      module = nikita.get ['does', 'not', 'exists']
      (module is null).should.be.true()

    it 'get all', ->
      modules = nikita.get()
      modules.file.properties[''].handler.should.be.type 'function'

    it 'get all with deprecated', ->
      nikita.register ['new', 'function'], handler: (->)
      nikita.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      modules = nikita.get deprecate: false
      modules['new']['function'][''].handler.should.be.type 'function'
      (modules['old'] is undefined).should.be.true()
      modules = nikita.get deprecate: true
      modules['new']['function'][''].handler.should.be.type 'function'
      modules['old']['function'][''].handler.should.be.type 'function'

    it 'get all with flatten options', ->
      nikita.register ['my', 'function'], handler: (->)
      modules = nikita.get flatten: true
      modules['my.function'].handler.should.be.type 'function'
      nikita.unregister ['my', 'function']

    it 'get all with flatten options and deprecate', ->
      nikita.register ['new', 'function'], handler: (->)
      nikita.deprecate ['old', 'function'], ['new', 'function'], handler: (->)
      modules = nikita.get flatten: true, deprecate: false
      modules['new.function'].handler.should.be.type 'function'
      (modules['old.function'] is undefined).should.be.true()
      modules = nikita.get flatten: true, deprecate: true
      modules['new.function'].handler.should.be.type 'function'
      modules['old.function'].handler.should.be.type 'function'
