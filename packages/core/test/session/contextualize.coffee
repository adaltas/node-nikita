
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
  
  it '$ is specific to each argument', ->
    contextualize args: [
      { $: false, $metadata: true },
      { $parent: true }
      { $: false, $hooks: true }
      { $config: true }
    ]
    .should.eql
      config: true,
      metadata: {},
      $metadata: true,
      parent: true,
      $hooks: true
  
  it '$ enable long mode with config', ->
    a_config_1 = { a_key_1: '1', a_key_overwritten: { a_key: 'overwrite 1'}}
    a_config_2 = { a_key_2: '2', a_key_overwritten: { a_key: 'overwrite 2'}}
    contextualize args: [
      $: false
      config: a_config_1
    ,
      $: false
      config: a_config_2
    ]
    .config.should.eql
      a_key_1: '1'
      a_key_overwritten: a_key: 'overwrite 2'
      a_key_2: '2'
    
  it '$ enable long mode with metadata', ->
    contextualize args: [
      $: false
      metadata: { a_key_1: '1', a_key_overwritten: { a_key: 'overwrite 1'}}
    ,
      $: false
      metadata: { a_key_2: '2', a_key_overwritten: { a_key: 'overwrite 2'}}
    ]
    .metadata.should.eql
      a_key_1: '1'
      a_key_overwritten: a_key: 'overwrite 2'
      a_key_2: '2'
    
  it '$ keys in first level unless config or metadata', ->
    an_arg_1 = { a_key_1: '1', a_key_overwritten: { a_key: 'overwrite 1'}}
    an_arg_2 = { a_key_2: '2', a_key_overwritten: { a_key: 'overwrite 2'}}
    contextualize args: [
      $: false
      a_key_1: '1'
      a_key_overwritten: { a_key: 'overwrite 1'}
    ,
      $: false
      a_key_2: '2'
      a_key_overwritten: { a_key: 'overwrite 2'}
    ]
    .should.eql
      a_key_1: '1'
      a_key_overwritten: a_key: 'overwrite 2'
      a_key_2: '2'
      config: {}
      metadata: {}
