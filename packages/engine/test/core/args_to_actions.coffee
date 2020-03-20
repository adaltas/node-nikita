
args_to_actions = require '../../src/args_to_actions'
{multiply} = args_to_actions

# Test the construction of the session namespace stored in state

describe 'args_to_actions', ->

  describe 'multiply', ->
    
    it 'takes only objects', ->
      multiply [
        {a: ''},
        {b: ''}
      ]
      .should.eql [
        [{a: ''}, {b: ''}]
      ]
        
    it 'takes array', ->
      multiply [
        [{a: ''}, {b: ''}],
        [{c: ''}, {d: ''}]
      ]
      .should.eql [
        [{a: ''}, {c: ''}],
        [{b: ''}, {c: ''}],
        [{a: ''}, {d: ''}],
        [{b: ''}, {d: ''}]
      ]
        
    it 'string and array', ->
      multiply [
        'a',
        [{b: ''}, {c: ''}]
        'd',
      ]
      .should.eql [
        ['a', {b: ''}, 'd'],
        ['a', {c: ''}, 'd']
      ]

  describe 'args_to_actions', ->
    
    it 'handle function as handler', ->
      expect = [
        handler: (->)
        metadata: {}
        options: b: ''
      ,
        handler: (->)
        metadata: {}
        options: c: ''
      ]
      # String is place before objects
      args_to_actions [
        (->)
        [{b: ''}, {c: ''}]
      ]
      .should.eql expect
      # String is place after objects
      args_to_actions [
        [{b: ''}, {c: ''}]
        (->)
      ]
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
      args_to_actions [
        'a'
        [{b: ''}, {c: ''}]
      ]
      .should.eql expect
      # String is place after objects
      args_to_actions [
        [{b: ''}, {c: ''}]
        'a'
      ]
      .should.eql expect
