
nikita = require '../../src'
{tags, scratch} = require '../test'

return unless tags.api

describe 'metadata "get"', ->
  
  describe 'passed to action', ->

    it 'synchronous call', ->
      n = nikita
      result = n.call
        get: true
        handler: -> 'get me'
      result.should.eql 'get me'

    it 'synchronous registered action', ->
      n = nikita
      n.registry.register ['an', 'action'],
        get: true
        handler: -> 'get me'
      result = n.an.action()
      result.should.eql 'get me'

    it 'clone options', ->
      my_options = a_key: 'a value'
      n = nikita
      n.call
        get: true
      , my_options
      , ({options}) ->
        options['a_key'] = 'should not be visible'
      n.next ->
        my_options['a_key'].should.eql 'a value'
      n.promise()
      
  describe 'defined in action', ->
    
    it 'honors cascade in registered action as object', ->
      nikita()
      .registry.register( 'my_action',
        get: true
        cascade:
          option_true: true
          option_false: false
        handler: ({options}) ->
          return
            option_true: options.option_true
            option_false: options.option_false
      )
      .my_action
        option_true: 'ok'
        option_false: 'ok'
      .should.eql
        option_true: 'ok'
        option_false: undefined
    
    it 'honors cascade in registered action as module', ->
      nikita
      .file
        target: "#{scratch}/my_action.coffee"
        content: """
        module.exports =
          get: true
          cascade:
            option_true: true
            option_false: false
          handler: ({options}) ->
            return
              option_true: options.option_true
              option_false: options.option_false
        """
      .call ({options}) ->
        nikita()
        .registry.register 'my_action', "#{scratch}/my_action"
        .my_action
          option_true: 'ok'
          option_false: 'ok'
        .should.eql
          option_true: 'ok'
          option_false: undefined
      .promise()
