
mecano = require '../../src'
test = require '../test'

describe 'api get', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'get module', ->
      module = mecano.get ['file', 'properties']
      module.handler.should.be.type 'function'

    it 'get unregistered module', ->
      module = mecano.get ['does', 'not', 'exists']
      console.log 'todo registry.get', module

    it 'get all modules', ->
      modules = mecano.get()
      modules.file.properties[''].handler.should.be.type 'function'
