
contextualize = require '../../src/action/contextualize'
normalize = require '../../src/action/normalize'

describe 'action.contextualize', ->
  
  it 'handle function as handler', ->
    expect = [
      handler: (->)
      config: b: ''
    ,
      handler: (->)
      config: c: ''
    ]
    # String is place before objects
    normalize contextualize [
      (->)
      [{b: ''}, {c: ''}]
    ]
    # Filter only metadata.argument and config
    .map (el) ->
      handler: el.handler
      config: el.config
    .should.eql expect
    # String is place after objects
    normalize contextualize [
      [{b: ''}, {c: ''}]
      (->)
    ]
    # Filter only metadata.argument and config
    .map (el) ->
      handler: el.handler
      config: el.config
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect = [
      metadata: argument: 'a'
      config: b: ''
    ,
      metadata: argument: 'a'
      config: c: ''
    ]
    # String is place before objects
    normalize contextualize [
      'a'
      [{b: ''}, {c: ''}]
    ]
    # Filter only metadata.argument and config
    .map (el) ->
      metadata: argument: el.metadata.argument
      config: el.config
    .should.eql expect
    # String is place after objects
    normalize contextualize [
      [{b: ''}, {c: ''}]
      'a'
    ]
    # Filter only metadata.argument and config
    .map (el) ->
      metadata: argument: el.metadata.argument
      config: el.config
    .should.eql expect
