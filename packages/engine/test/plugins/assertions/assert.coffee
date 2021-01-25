
nikita = require '../../../src'
return
describe 'plugin.assertions assert', ->
  
  describe 'array', ->

    it.skip 'run if all conditions are `true`', ->
      nikita.call
        assert: [true, true]
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it.skip 'skip if one conditions is `false`', ->
      nikita.call
        assert: [true, false, true]
        handler: -> true
      .should.be.rejectedWith
        code: 'NIKITA_INVALID_ASSERTION'
  
  describe 'boolean, integer', ->

    it.skip 'run if `true`', ->
      nikita.call
        assert: true
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it.skip 'skip if `false`', ->
      nikita.call
        assert: false
        handler: -> throw Error 'forbidden'

    it.skip 'run if `1`', ->
      nikita.call
        assert: 1
        handler: -> 'called'
      .should.finally.eql 'called'

    it.skip 'skip if `0`', ->
      nikita.call
        if: 0
        handler: -> throw Error 'forbidden'
          
  describe 'null, undefined', ->

    it.skip 'skip if `null`', ->
      nikita.call
        assert: null
        handler: -> throw Error 'forbidden'

    it.skip 'skip if `undefined`', ->
      nikita.call
        assert: undefined
        handler: -> throw Error 'forbidden'
  
  describe 'string + buffer', ->
  
    it.skip 'run if `"string"`', ->
      nikita.call
        assert: 'abc'
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it.skip 'run if `{{"string"}}`', -> # was skipped
      count = 0
      nikita
      .call
        assert: '{{config.db.test}}'
        db: test: 'abc'
      , ->
        count++
      .call ->
        count.should.equal 1

    it.skip 'skip if `""`', -> # was skipped
      nikita.call
        assert: ''
        handler: -> throw Error 'forbidden'

    it.skip 'skip if `{{""}}`',->
      nikita.call
        assert: '{{config.db.test}}'
        db: test: ''
        handler: -> throw Error 'forbidden'

    it 'run if buffer length > 1', ->
      nikita.call
        assert: Buffer.from 'abc'
        handler: -> 'called'
      .should.finally.eql 'called'

    it 'skip if buffer length is empty', ->
      nikita.call
        assert: Buffer.from ''
        handler: -> throw Error 'forbidden'
    
  describe 'object', ->

    it 'run if `{k:v}`', ->
      nikita.call
        assert: {k:"v"}
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip if `{}`', ->
      nikita.call
        assert: {}
        handler: -> throw Error 'forbidden'
  
  describe 'function', ->

    it.only 'resolve function returns true', ->
      {status} = await nikita.call
        assert: -> true
        handler: (-> true)
      status.should.be.true()
      {status} = await nikita.call
        assert: -> new Promise (resolve) -> setImmediate resolve
        handler: (-> true)
      status.should.be.true()

    it 'reject if function returns false', ->
      nikita.call
        assert: -> false
        handler: (->)
      .should.be.rejectedWith
        code: 'NIKITA_INVALID_ASSERTION'
      await nikita.call
        assert: -> new Promise (resolve, reject) ->
          # setImmediate reject
          # reject()
          # resolve 'ok'
          reject Error 'ko'
        # assert: ->
        #   throw Error 'ok'
        handler: (->)
      # .should.be.rejectedWith
      #   code: 'NIKITA_INVALID_ASSERTION'

    it 'all assertions must validate', ->
      # All assertions are true
      {status, value} = await nikita.call
        assert: [
          -> true
          -> true
        ]
        handler: -> status: true, value: 'called'
      status.should.be.true()
      value.should.eql 'called'
      # Not all assertions are true
      {status, value} = await nikita.call
        assert: [
          -> true
          -> false
        ]
        handler: -> status: true, value: 'called'
      .should.be.rejectedWith
        code: 'NIKITA_INVALID_ASSERTION'

    it.skip 'skip if promise resolves with false', ->
      {status, value} = await nikita.call
        assert: ->
          new Promise (accept, reject) -> accept false
        handler: -> throw Error 'You are not welcome here'
      status.should.be.false()

    it.skip 'function pass config', ->
      nikita.call
        assert: ({config}) ->
          config.a_key.should.eql 'a value'
        a_key: 'a value'
        handler: -> 'success'
      .should.be.finally.eql 'success'
    
