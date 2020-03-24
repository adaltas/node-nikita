
nikita = require '../../src'
registry = require '../../src/registry'

describe 'session registry', ->

  describe 'access', ->
    
    it 'available statically', ->
      nikita.registry.get().should.be.an.Object()
        
    it 'available from instance', ->
      nikita.registry.get().should.be.an.Object()
        
    it 'available inside action', ->
      nikita ({registry}) ->
        registry.get().should.be.an.Object()
          
    it 'available inside context', ->
      nikita ({context}) ->
        context.registry.get().should.be.an.Object()

  describe 'action', ->

    it 'called from local registry', ->
      nikita
      .call ({context, registry})->
        registry.register 'my_function', ({options}) ->
          pass_a_key: options.a_key
        {pass_a_key} = await this.my_function a_key: 'a value'
        pass_a_key.should.eql 'a value'

    it 'overwrite registration with namespace argument', ->
      nikita ({registry}) ->
        # Register a namespace
        registry.register ['my', 'function'], key: 'a', handler: ({options}) -> options.key
        registry.register ['my', 'function'], key: 'b', handler: ({options}) -> options.key
        result = await @my.function()
        result.should.eql 'b'

    it 'overwrite registration object argument', ->
      nikita ({registry}) ->
        registry.register
          'my': 'function': key: 'a', handler: ({options}) -> options.key
        registry.register
          'my': 'function': key: 'b', handler: ({options}) -> options.key
        result = await @my.function()
        result.should.eql 'b'

describe 'error', ->

  it 'root action not defined', ->
    (->
      nikita().invalid()
    ).should.throw 'nikita(...).invalid is not a function'

  it 'action undefined inside a registered namespace', ->
    (->
      nikita ({regitry}) ->
        registry.register ['ok', 'and', 'valid'], (->)
      .ok.and.invalid()
    ).should.throw 'nikita(...).ok.and.invalid is not a function'

  it 'parent name not defined child action undefined', ->
    (->
      nikita().not.an.action()
    ).should.throw 'Cannot read property \'an\' of undefined'
