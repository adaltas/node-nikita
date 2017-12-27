
nikita = require '../../src'

describe 'registry.registered', ->

  describe 'global', ->

    it 'return false with 1 level', ->
      (nikita.registry.registered 'does_not_exists').should.be.false()
      (nikita.registry.registered ['does_not_exists']).should.be.false()

    it 'return false with multi level', ->
      (nikita.registry.registered ['does', 'not', 'exists']).should.be.false()

    it 'return true with 1 level', ->
      nikita.registry.register ['my_module'], (->)
      (nikita.registry.registered 'my_module').should.be.true()
      (nikita.registry.registered ['my_module']).should.be.true()
      nikita.registry.unregister ['my_module']

    it 'return true with multi level', ->
      nikita.registry.register ['my', 'module'], (->)
      (nikita.registry.registered ['my', 'module']).should.be.true()
      (nikita.registry.registered ['my']).should.be.false()
      nikita.registry.unregister ['my', 'module']

    it 'option parent', ->
      nikita.registry.register ['my', 'nice', 'module'], (->)
      nikita.registry.registered(['my'], parent: true).should.be.true()
      nikita.registry.registered(['my', 'nice'], parent: true).should.be.true()
      nikita.registry.unregister ['my', 'nice', 'module']

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

    it 'option parent', ->
      n = nikita()
      n.registry.register ['my', 'nice', 'module'], (->)
      n.registry.registered(['my'], parent: true).should.be.true()
      n.registry.registered(['my', 'nice'], parent: true).should.be.true()
