
nikita = require '../../src'

describe 'action `handler`', ->
  
  describe 'return', ->

    it 'return a user resolved promise', ->
      nikita.call
        handler: ({options}) ->
          new Promise (accept, reject) ->
            setImmediate -> accept output: 'ok'
      .should.be.resolvedWith output: 'ok'

    it 'return an action resolved promise', ->
      nikita.call
        handler: ({options}) ->
          @call
            handler: ->
              new Promise (accept, reject) ->
                setImmediate -> accept output: 'ok'
      .should.be.resolvedWith output: 'ok'
          
