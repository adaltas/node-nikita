
nikita = require '../../src'

describe 'registry.registered', ->

  describe 'global', ->

    it 'return false with 1 level', ->
      (nikita.registered 'does_not_exists').should.be.false()
      (nikita.registered ['does_not_exists']).should.be.false()

    it 'return false with multi level', ->
      (nikita.registered ['does', 'not', 'exists']).should.be.false()

    it 'return true with 1 level', ->
      nikita.register ['my_module'], (->)
      (nikita.registered 'my_module').should.be.true()
      (nikita.registered ['my_module']).should.be.true()
      nikita.unregister ['my_module'], (->)

    it 'return true with multi level', ->
      nikita.register ['my', 'module'], (->)
      (nikita.registered ['my', 'module']).should.be.true()
      (nikita.registered ['my']).should.be.false()
      nikita.unregister ['my', 'module'], (->)

  describe 'local', ->

    it 'return false with 1 level', ->
      (nikita().registry.registered 'does_not_exists').should.be.false()
      (nikita().registry.registered ['does_not_exists']).should.be.false()

    it 'return false with multi level ', ->
      (nikita().registry.registered ['does', 'not', 'exists']).should.be.false()

    it 'return true with 1 level', ->
      n = nikita()
      n.registry.register ['my_module'], (->)
      n.registry.registered('my_module').should.be.true()
      n.registry.registered(['my_module']).should.be.true()

    it 'return true with multi level', ->
      n = nikita()
      n.registry.register ['my', 'module'], (->)
      n.registry.registered(['my', 'module']).should.be.true()
      n.registry.registered(['my']).should.be.false()
