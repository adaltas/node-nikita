
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
      console.log 'todo registry.get', module

    it 'get all modules', ->
      modules = nikita.get()
      modules.file.properties[''].handler.should.be.type 'function'
