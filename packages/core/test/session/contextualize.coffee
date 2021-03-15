
{tags} = require '../test'
contextualize = require '../../src/session/contextualize'
normalize = require '../../src/session/normalize'

describe 'session.contextualize', ->
  return unless tags.api
  
  it 'handle function as handler', ->
    expect =
      config: a: ''
      handler: (->)
      metadata: {}, hooks: {}, state: {}
    # String is place before objects
    contextualize [
      (->)
      {a: ''}
    ]
    .should.eql expect
    # String is place after objects
    contextualize [
      {a: ''}
      (->)
    ]
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect =
      config: b: ''
      metadata: argument: 'a'
      hooks: {}, state: {}
    # String is place before objects
    contextualize [
      'a'
      {b: ''}
    ]
    .should.eql expect
    # String is place after objects
    contextualize [
      {b: ''}
      'a'
    ]
    .should.eql expect
  
  it 'metadata as $$ object', ->
    expect =
      metadata: a: '1', b: '2'
      config: b: ''
      hooks: {}
      state: {}
    # Metadata in first argument
    contextualize [
      $$: a: '1', b: '2'
      b: ''
    ]
    .should.eql expect
    # Metadata are overwritten
    contextualize [
      $$: a: 'x', b: 'x'
      {b: '', $a: '1', $b: '2'}
    ]
    .should.eql expect
