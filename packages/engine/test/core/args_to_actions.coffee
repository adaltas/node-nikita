
args_to_actions = require '../../src/args_to_actions'
{multiply, reconstituate, ventilate} = args_to_actions

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
        options: b: ''
      ,
        handler: (->)
        options: c: ''
      ]
      # String is place before objects
      ventilate reconstituate multiply [
        (->)
        [{b: ''}, {c: ''}]
      ]
      # Filter only metadata.argument and options
      .map (el) ->
        handler: el.handler
        options: el.options
      .should.eql expect
      # String is place after objects
      ventilate reconstituate multiply [
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
      ventilate reconstituate multiply [
        'a'
        [{b: ''}, {c: ''}]
      ]
      # Filter only metadata.argument and options
      .map (el) ->
        metadata: argument: el.metadata.argument
        options: el.options
      .should.eql expect
      # String is place after objects
      ventilate reconstituate multiply [
        [{b: ''}, {c: ''}]
        'a'
      ]
      # Filter only metadata.argument and options
      .map (el) ->
        metadata: argument: el.metadata.argument
        options: el.options
      .should.eql expect
