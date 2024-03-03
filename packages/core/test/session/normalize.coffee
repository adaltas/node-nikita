
import contextualize from '@nikitajs/core/session/contextualize'
import normalize from '@nikitajs/core/session/normalize'
import test from '../test.coffee'

describe 'session.normalize', ->
  return unless test.tags.api
  
  it 'handle function as handler', ->
    expect =
      handler: (->)
      config: a: ''
      metadata: {}
    # String is place before objects
    normalize contextualize args: [
      (->)
      {a: ''}
    ]
    # Filter only metadata.argument and config
    .should.eql expect
    # String is place after objects
    normalize contextualize args: [
      {a: ''}
      (->)
    ]
    # Filter only metadata.argument and config
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect =
      metadata: argument: 'a'
      config: b: ''
    # String is place before objects
    normalize contextualize args: [
      'a'
      {b: ''}
    ]
    # Filter only metadata.argument and config
    .should.eql expect
    # String is place after objects
    normalize contextualize args: [
      {b: ''}
      'a'
    ]
    # Filter only metadata.argument and config
    .should.eql expect
