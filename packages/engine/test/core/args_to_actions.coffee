
args_to_actions = require '../../src/args_to_actions'
{build, ventilate} = args_to_actions

# Test the construction of the session namespace stored in state

describe 'args_to_actions', ->

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
      ventilate build [
        (->)
        [{b: ''}, {c: ''}]
      ]
      # Filter only metadata.argument and options
      .map (el) ->
        handler: el.handler
        options: el.options
      .should.eql expect
      # String is place after objects
      ventilate build [
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
      ventilate build [
        'a'
        [{b: ''}, {c: ''}]
      ]
      # Filter only metadata.argument and options
      .map (el) ->
        metadata: argument: el.metadata.argument
        options: el.options
      .should.eql expect
      # String is place after objects
      ventilate build [
        [{b: ''}, {c: ''}]
        'a'
      ]
      # Filter only metadata.argument and options
      .map (el) ->
        metadata: argument: el.metadata.argument
        options: el.options
      .should.eql expect
