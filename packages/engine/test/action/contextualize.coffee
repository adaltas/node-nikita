
contextualize = require '../../src/action/contextualize'
normalize = require '../../src/action/normalize'

describe 'action.contextualize', ->
  
  it 'handle function as handler', ->
    expect = [
      handler: (->)
      b: ''
    ,
      handler: (->)
      c: ''
    ]
    # String is place before objects
    contextualize [
      (->)
      [{b: ''}, {c: ''}]
    ]
    .should.eql expect
    # String is place after objects
    contextualize [
      [{b: ''}, {c: ''}]
      (->)
    ]
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect = [
      metadata: argument: 'a'
      b: ''
    ,
      metadata: argument: 'a'
      c: ''
    ]
    # String is place before objects
    contextualize [
      'a'
      [{b: ''}, {c: ''}]
    ]
    .should.eql expect
    # String is place after objects
    contextualize [
      [{b: ''}, {c: ''}]
      'a'
    ]
    .should.eql expect
