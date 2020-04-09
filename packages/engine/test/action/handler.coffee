
nikita = require '../../src'

describe 'action `handler`', ->
  
  describe 'return', ->

    it 'return a user resolved promise', ->
      nikita.call
        handler: ({config}) ->
          new Promise (accept, reject) ->
            setImmediate -> accept output: 'ok'
      .should.be.resolvedWith output: 'ok', status: false

    it 'return an action resolved promise', ->
      nikita.call
        handler: ({config}) ->
          @call
            handler: ->
              new Promise (accept, reject) ->
                setImmediate -> accept output: 'ok'
      .should.be.resolvedWith output: 'ok', status: false
          
