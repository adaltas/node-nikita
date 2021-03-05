
{tags} = require '../test'
contextualize = require '../../src/session/contextualize'
normalize = require '../../src/session/normalize'

describe 'session.contextualize', ->
  return unless tags.api
  
  it 'handle function as handler', ->
    expect = [
      config: b: ''
      handler: (->)
      metadata: {}, hooks: {}, state: {}
    ,
      config: c: ''
      handler: (->)
      metadata: {}, hooks: {}, state: {}
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
      config: b: ''
      metadata: argument: 'a'
      hooks: {}, state: {}
    ,
      config: c: ''
      metadata: argument: 'a'
      hooks: {}, state: {}
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
  
  it 'metadata as $$ object', ->
    expect = [
      metadata: a: '1', b: '2'
      config: b: ''
    ,
      metadata: a: '1', b: '2'
      config: c: ''
    ]
    # Metadata in first argument
    contextualize [
      $$: a: '1', b: '2'
      [{b: ''}, {c: ''}]
    ]
    .map (el) ->
      metadata:
        a: el.metadata.a
        b: el.metadata.b
      config: el.config
    .should.eql expect
    # Metadata are overwritten
    contextualize [
      $$: a: 'x', b: 'x'
      [{b: '', $a: '1', $b: '2'}, {c: '', $$: a: '1', b: '2'}]
    ]
    .map (el) ->
      metadata:
        a: el.metadata.a
        b: el.metadata.b
      config: el.config
    .should.eql expect
