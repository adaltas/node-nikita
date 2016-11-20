
mecano = require '../../src'
test = require '../test'

describe 'api register', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'return false', ->
      (mecano.registered 'does_not_exists').should.be.false()
      (mecano.registered ['does_not_exists']).should.be.false()



  describe 'local', ->

    it 'return false', ->
      (mecano().registry.registered 'does_not_exists').should.be.false()
      (mecano().registry.registered ['does_not_exists']).should.be.false()
