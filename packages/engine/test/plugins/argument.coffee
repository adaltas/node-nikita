
nikita = require '../../src'

describe 'plugins.argument', ->
  
  it 'enrich config', ->
    nikita
      argument: 'my_key'
    , 'my value', ({config}) ->
      config.should.eql my_key: 'my value'
        
  it 'dont overwrite config', ->
    nikita
      argument: 'my_key'
      my_key: 'my original value'
    , 'my new value', ({config}) ->
      config.should.eql my_key: 'my original value'
