
nikita = require '../../src'

describe 'operation.find', ->

  it 'start in current action', ->
    nikita.call a_key: 'a value', ->
      @operations.find (action) ->
        action.options.a_key
      .should.be.resolvedWith 'a value'

  it 'start traverse the parent hierarchy', ->
    nikita.call a_key: 'a value', ->
      @call ->
        count = 0
        @operations.find (action) ->
          count++
          return unless action.options.a_key
          a_key: action.options.a_key, depth: action.metadata.depth
        .should.be.resolvedWith a_key: 'a value', depth: 1
        .then -> count.should.eql 2

  it 'start traverse the parent hierarchy', ->
    nikita.call a_key: 'a value', ->
      @call -> @call -> @call -> @call (action) ->
        count = 0
        @operations.find action.parent.parent, (action) ->
          count++
          return unless action.options.a_key
          a_key: action.options.a_key, depth: action.metadata.depth
        .should.be.resolvedWith a_key: 'a value', depth: 1
        .then -> count.should.eql 2
