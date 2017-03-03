
nikita = require '../../src'
test = require '../test'

describe 'registry.register', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'return false', ->
      (nikita.registered 'does_not_exists').should.be.false()
      (nikita.registered ['does_not_exists']).should.be.false()



  describe 'local', ->

    it 'return false', ->
      (nikita().registry.registered 'does_not_exists').should.be.false()
      (nikita().registry.registered ['does_not_exists']).should.be.false()
