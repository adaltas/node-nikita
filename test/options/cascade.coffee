
nikita = require '../../src'
context = require '../../src/context'

describe 'options "cascade"', ->
  
  describe 'globally', ->
  
    it 'pass the cascade option', ->
      context.cascade.global_option_true = true
      context.cascade.global_option_false = false
      nikita
      # Test the cascade option
      .call (options) ->
        options.cascade.global_option_true.should.true()
        options.cascade.global_option_false.should.false()
        @call (options) ->
          options.cascade.global_option_true.should.true()
          options.cascade.global_option_false.should.false()
      # Cleanup
      .call ->
        delete context.cascade.global_option_true
        delete context.cascade.global_option_false
      .promise()
      
    it 'pass the action cascaded value', ->
      context.cascade.global_option_true = true
      context.cascade.global_option_false = false
      nikita
      # Test the action cascaded value
      .call
        global_option_true: 'value'
        global_option_false: 'value'
      , (options) ->
        options.global_option_true.should.equal 'value'
        (options.global_option_false is undefined).should.be.true()
        @call (options) ->
          options.global_option_true.should.equal 'value'
          (options.global_option_false is undefined).should.be.true()
          @call (options) ->
            options.global_option_true.should.equal 'value'
            (options.global_option_false is undefined).should.be.true()
      # Cleanup
      .call ->
        delete context.cascade.global_option_true
        delete context.cascade.global_option_false
      .promise()
        
  describe 'defined in session', ->

    it 'pass the cascade option', ->
      nikita
        cascade:
          option_true: true
          option_false: false
      # Test the cascade option
      .call (options) ->
        options.cascade.option_true.should.be.true()
        options.cascade.option_false.should.be.false()
        (options.cascade.option_undefined is undefined).should.be.true()
        # Call child
        @call (options) ->
          options.cascade.option_true.should.be.true()
          options.cascade.option_false.should.be.false()
          (options.cascade.option_undefined is undefined).should.be.true()
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
      , (options) ->
        options.option_true.should.eql 'value'
        (options.option_false is undefined).should.be.true()
        options.option_undefined.should.eql 'value'
        # Call child
        @call (options) ->
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
      .call (options) ->
        options.a_session_key.should.eql 'value'
        # Overwrite the option with null value
        @call a_session_key: null, (options) ->
          (options.a_session_key is null).should.be.true()
          @call (options) ->
            (options.a_session_key is null).should.be.true()
      # Ensure the session value is preserve
      .call (options) ->
        options.a_session_key.should.eql 'value'
      .promise()
        
  describe 'passed to action', ->
    
    it 'cascade option cascaded', ->
      nikita
      .call 
        cascade:
          option_true: true
          option_false: false
      , (options) ->
        options.cascade.option_true.should.be.true()
        options.cascade.option_false.should.be.false()
        @call (options) ->
          options.cascade.option_true.should.be.true()
          options.cascade.option_false.should.be.false()
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
      , (options) ->
        options.cascade.key_a.should.be.true()
        options.cascade.key_b.should.be.true()
        options.cascade.key_c.should.be.true()
        @call (options) ->
          # Check if key_* are cascaded into child
          options.cascade.key_a.should.be.true()
          options.cascade.key_b.should.be.true()
          options.cascade.key_c.should.be.true()
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
      , (options) ->
        options.overwritten_true.should.equal 'a'
        (options.overwritten_false is undefined).should.be.true()
        options.session_b.should.equal 'b'
        options.action_c.should.equal 'c'
        # Check if key_* are cascaded into child
        @call (options) ->
          options.overwritten_true.should.equal 'a'
          (options.overwritten_false is undefined).should.be.true()
          options.session_b.should.equal 'b'
          options.action_c.should.equal 'c'
      .promise()
