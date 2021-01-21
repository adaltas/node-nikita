
nikita = require '../../../src'

describe 'plugin.condition', ->

  it 'normalize', ->
    nikita ->
      @call
        if: true
      , ({conditions}) ->
        conditions.if.should.be.eql [true]
    
  it 'before schema', ->
    {status} = await nikita.call
      if: false
      metadata:
        schema:
          type: 'object'
          properties: 'a_key': type: 'boolean'
          required: ['a_key']
    , -> true
    status.should.be.false()
    
