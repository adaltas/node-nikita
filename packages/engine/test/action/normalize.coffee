
contextualize = require '../../src/action/contextualize'
normalize = require '../../src/action/normalize'

describe 'action.contextualize', ->
  
  it 'handle function as handler', ->
    expect = [
      handler: (->)
      options: b: ''
    ,
      handler: (->)
      options: c: ''
    ]
    # String is place before objects
    normalize contextualize [
      (->)
      [{b: ''}, {c: ''}]
    ]
    # Filter only metadata.argument and options
    .map (el) ->
      handler: el.handler
      options: el.options
    .should.eql expect
    # String is place after objects
    normalize contextualize [
      [{b: ''}, {c: ''}]
      (->)
    ]
    # Filter only metadata.argument and options
    .map (el) ->
      handler: el.handler
      options: el.options
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect = [
      metadata: argument: 'a'
      options: b: ''
    ,
      metadata: argument: 'a'
      options: c: ''
    ]
    # String is place before objects
    normalize contextualize [
      'a'
      [{b: ''}, {c: ''}]
    ]
    # Filter only metadata.argument and options
    .map (el) ->
      metadata: argument: el.metadata.argument
      options: el.options
    .should.eql expect
    # String is place after objects
    normalize contextualize [
      [{b: ''}, {c: ''}]
      'a'
    ]
    # Filter only metadata.argument and options
    .map (el) ->
      metadata: argument: el.metadata.argument
      options: el.options
    .should.eql expect
