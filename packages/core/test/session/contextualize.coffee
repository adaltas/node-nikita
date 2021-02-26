
{tags} = require '../test'
contextualize = require '../../src/session/contextualize'
normalize = require '../../src/session/normalize'

describe 'session.contextualize', ->
  return unless tags.api
  
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
