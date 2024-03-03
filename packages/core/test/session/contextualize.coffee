
import test from '../test.coffee'
import contextualize from '../../lib/session/contextualize.js'

describe 'session.contextualize', ->
  return unless test.tags.api
  
  it 'handle function as handler', ->
    expect =
      config: a: ''
      handler: (->)
      metadata: {}
    # String is place before objects
    contextualize args: [
      (->)
      {a: ''}
    ]
    .should.eql expect
    # String is place after objects
    contextualize args: [
      {a: ''}
      (->)
    ]
    .should.eql expect
  
  it 'handle string as metadata.argument', ->
    expect =
      config: b: ''
      metadata: argument: 'a'
    # String is place before objects
    contextualize args: [
      'a'
      {b: ''}
    ]
    .should.eql expect
    # String is place after objects
    contextualize args: [
      {b: ''}
      'a'
    ]
    .should.eql expect
  
  it '$ merge config in first level', ->
    a_config_1 = { a_key_1: '1', a_key_overwritten: { a_key: 'overwrite 1'}}
    a_config_2 = { a_key_2: '2', a_key_overwritten: { a_key: 'overwrite 2'}}
    contextualize args: [
      $: config: a_config_1
    ,
      $: config: a_config_2
    ]
    .config.should.eql
      a_key_1: '1'
      a_key_overwritten: a_key: 'overwrite 2'
      a_key_2: '2'
    
  it '$ merge metadata in first level', ->
    a_metadata_1 = { a_key_1: '1', a_key_overwritten: { a_key: 'overwrite 1'}}
    a_metadata_2 = { a_key_2: '2', a_key_overwritten: { a_key: 'overwrite 2'}}
    contextualize args: [
      $: metadata: a_metadata_1
    ,
      $: metadata: a_metadata_2
    ]
    .metadata.should.eql
      a_key_1: '1'
      a_key_overwritten: a_key: 'overwrite 2'
      a_key_2: '2'
    
  it '$ keys in first level unless config or metadata', ->
    an_arg_1 = { a_key_1: '1', a_key_overwritten: { a_key: 'overwrite 1'}}
    an_arg_2 = { a_key_2: '2', a_key_overwritten: { a_key: 'overwrite 2'}}
    result = contextualize args: [
      $: an_arg_1
    ,
      $: an_arg_2
    ]
    {
      a_key_1: result.a_key_1
      a_key_overwritten: result.a_key_overwritten
      a_key_2: result.a_key_2
    }.should.eql
      a_key_1: '1'
      a_key_overwritten: a_key: 'overwrite 2'
      a_key_2: '2'
  
  it '$$ interpreted as metadata', ->
    expect =
      metadata: a: '1', b: '2'
      config: b: ''
    # Metadata in first argument
    contextualize args: [
      $$: a: '1', b: '2'
      b: ''
    ]
    .should.eql expect
    # Metadata are overwritten
    contextualize args: [
      $$: a: 'x', b: 'x'
      {b: '', $a: '1', $b: '2'}
    ]
    .should.eql expect
