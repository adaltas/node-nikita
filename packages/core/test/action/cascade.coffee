
nikita = require '../../src'
session = require '../../src/session'
{tags} = require '../test'

return unless tags.api

describe 'cascade', ->
  
  describe 'globally', ->
  
    it 'pass the cascade option', ->
      session.cascade.global_option_true = true
      session.cascade.global_option_false = false
      nikita
      # Test the cascade option
      .call ({options, cascade}) ->
        cascade.global_option_true.should.true()
        cascade.global_option_false.should.false()
        @call ({options, cascade}) ->
          cascade.global_option_true.should.true()
          cascade.global_option_false.should.false()
      # Cleanup
      .call ->
        delete session.cascade.global_option_true
        delete session.cascade.global_option_false
      .promise()
      
    it 'pass the action cascaded value', ->
      session.cascade.global_option_true = true
      session.cascade.global_option_false = false
      nikita
      # Test the action cascaded value
      .call
        global_option_true: 'value'
        global_option_false: 'value'
      , ({options}) ->
        options.global_option_true.should.equal 'value'
        (options.global_option_false is undefined).should.be.true()
        @call ({options}) ->
          options.global_option_true.should.equal 'value'
          (options.global_option_false is undefined).should.be.true()
          @call ({options}) ->
            options.global_option_true.should.equal 'value'
            (options.global_option_false is undefined).should.be.true()
      # Cleanup
      .call ->
        delete session.cascade.global_option_true
        delete session.cascade.global_option_false
      .promise()
        
  describe 'defined in session', ->

    it 'pass the cascade option', ->
      nikita
        cascade:
          option_true: true
          option_false: false
      # Test the cascade option
      .call ({cascade}) ->
        cascade.option_true.should.be.true()
        cascade.option_false.should.be.false()
        (cascade.option_undefined is undefined).should.be.true()
        # Call child
        @call ({cascade}) ->
          cascade.option_true.should.be.true()
          cascade.option_false.should.be.false()
          (cascade.option_undefined is undefined).should.be.true()
      .promise()

    it 'pass the action cascaded value', ->
      nikita
        cascade:
          option_true: true
          option_false: false
      # Test the cascaded value
      .call
        option_true: 'value'
        option_false: 'value'
        option_undefined: 'value'
      , ({options}) ->
        options.option_true.should.eql 'value'
        (options.option_false is undefined).should.be.true()
        options.option_undefined.should.eql 'value'
        # Call child
        @call ({options}) ->
          options.option_true.should.eql 'value'
          (options.option_false is undefined).should.be.true()
          (options.option_undefined is undefined).should.be.true()
      .promise()
        
    it 'session option is overwritten by action option', ->
      nikita
        a_session_key: 'value'
        cascade:
          a_session_key: true
      # Get the session value
      .call ({options}) ->
        options.a_session_key.should.eql 'value'
        # Overwrite the option with null value
        @call a_session_key: null, ({options}) ->
          (options.a_session_key is null).should.be.true()
          @call ({options}) ->
            (options.a_session_key is null).should.be.true()
      # Ensure the session value is preserve
      .call ({options}) ->
        options.a_session_key.should.eql 'value'
      .promise()
        
  describe 'passed to action', ->
    
    it 'cascade option cascaded', ->
      nikita
      .call
        cascade:
          option_true: true
          option_false: false
      , ({cascade}) ->
        cascade.option_true.should.be.true()
        cascade.option_false.should.be.false()
        @call ({cascade}) ->
          cascade.option_true.should.be.true()
          cascade.option_false.should.be.false()
      .promise()
        
    it 'cascade option merged with session options', ->
      nikita
        cascade:
          key_a: false
          key_b: true
      .call
        cascade:
          key_a: true
          key_c: true
      , ({cascade}) ->
        cascade.key_a.should.be.true()
        cascade.key_b.should.be.true()
        cascade.key_c.should.be.true()
        @call ({cascade}) ->
          # Check if key_* are cascaded into child
          cascade.key_a.should.be.true()
          cascade.key_b.should.be.true()
          cascade.key_c.should.be.true()
      .promise()
        
    it 'keys and values are cascaded if true', ->
      nikita
        cascade:
          overwritten_true: false
          overwritten_false: true
          session_b: true
      .call
        cascade:
          overwritten_true: true
          overwritten_false: false
          action_c: true
        overwritten_true: 'a'
        overwritten_false: 'a'
        session_b: 'b'
        action_c: 'c'
      , ({options}) ->
        options.overwritten_true.should.equal 'a'
        (options.overwritten_false is undefined).should.be.true()
        options.session_b.should.equal 'b'
        options.action_c.should.equal 'c'
        # Check if key_* are cascaded into child
        @call ({options}) ->
          options.overwritten_true.should.equal 'a'
          (options.overwritten_false is undefined).should.be.true()
          options.session_b.should.equal 'b'
          options.action_c.should.equal 'c'
      .promise()
    
    it 'can be declared as an array', ->
      nikita
      .call
        cascade: ['an_option']
        an_option: true
      , ({options}) ->
        options.an_option.should.be.true()
        @call ({options}) ->
          (options.an_option is undefined).should.be.true()
      .promise()
        
  describe 'values', ->
    
    it 'discard undefined values', ->
      nikita
        cascade:
          an_option: true
      .call
        an_option: 'is preserved'
      , ({options}) ->
        @call an_option: undefined, ({options}) ->
          options.an_option.should.eql 'is preserved'
      .promise()
        
    it 'cascade null values', ->
      nikita
        cascade: ['an_option']
      .call
        an_option: 'is overwritten by null'
      , ({options}) ->
        @call an_option: null, ({options}) ->
          (options.an_option is null).should.be.true()
      .promise()

    it 'cascade default values set by session', ->
      nikita()
      .registry.register 'a_module',
        cascade: sleep: true, retry: true, depth: true, shy: true
        handler: ({metadata}, callback) ->
          callback null,
            sleep: metadata.sleep
            retry: metadata.retry
            depth: metadata.depth
            shy: metadata.shy
      .call header:'a', sleep: 0, retry: 3, depth: 4, shy: true, ({metadata}) ->
        @a_module header:'b', (err, {sleep, retry, depth, shy}) ->
          throw err if err
          sleep.should.be.equal 0
          retry.should.be.equal 3
          depth.should.be.equal 4
          shy.should.be.true()
      .promise()

    it.skip 'print status', ->
      # This is open for debate
      # Currently, default options are not overwritten by cascaded options
      # We probably want the contrary
      nikita()
      .registry.register('a_module', a_key: false, cascade: {'a_key': true}, handler: ({options}, callback) ->
        callback null, a_key: options.a_key
      )
      .call a_key: true, ->
        @a_module (err, {a_key}) ->
          a_key.should.be.true() unless err
      .promise()

    it 'transmitted to get handler', ->
      batons = []
      nikita
        cascade: baton: true
      .registry.register( 'my_action', get: true, handler: ({metadata, options}) ->
        batons.push "#{metadata.argument} #{options.baton}"
      )
      .call
        baton: 'transmitted'
      , ->
        @call
          if: ->
            @my_action 'condition'
            true
        , ->
          @my_action 'handler'
        , ->
          @my_action 'callback'
      .call ->
        batons.should.eql [
          'condition transmitted'
          'handler transmitted'
          'callback transmitted'
        ]
      .promise()
