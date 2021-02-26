
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.argument', ->
  return unless tags.api
  
  it 'enrich config', ->
    nikita
      $argument_to_config: 'my_key'
    , 'my value', ({config}) ->
      config.should.eql my_key: 'my value'
        
  it 'dont overwrite config', ->
    nikita
      $argument_to_config: 'my_key'
      my_key: 'my original value'
    , 'my new value', ({config}) ->
      config.should.eql my_key: 'my original value'
