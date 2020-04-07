
{merge} = require 'mixme'
error = require '../utils/error'

module.exports = ->
  'nikita:session:normalize': (action) ->
    # Move property from action to metadata
    for property in ['attempt', 'sleep', 'retry']
      if action.hasOwnProperty property
        action.metadata[property] = action[property]
        delete action[property]
  'nikita:session:action': (action, handler) ->
    action.metadata.attempt ?= 0
    action.metadata.retry ?= 1
    action.metadata.sleep ?= 3000
    for property in ['attempt', 'sleep', 'retry']
      if typeof action.metadata[property] is 'number'
        if action.metadata[property] < 0
          throw error "METADATA_#{property.toUpperCase()}_INVALID_RANGE", [
            "option `#{property}` expect a number above or equal to 0,"
            "got #{action.metadata[property]}."
          ]
      else unless typeof action.metadata[property] is 'boolean'
        throw error "METADATA_#{property.toUpperCase()}_INVALID_VALUE", [
          "option `#{property}` expect a number or a boolean value,"
          "got #{JSON.stringify action.metadata[property]}."
        ]
    (action) ->
      args = arguments
      {retry} = action.metadata
      options = merge {}, action.options
      # Handle error
      failure = (err) ->
        throw err if retry isnt true and action.metadata.attempt >= retry - 1
        # Increment the attempt metadata
        action.metadata.attempt++
        action.options = merge {}, options
        # Reschedule
        run()
      run = ->
        try
          output = handler.call @, ...args
          if output and output.catch
            # Note, should.js return a PromisedAssertion with a `then` but
            # no `catch` function
            output.catch failure if output.catch
          else
            output
        catch err then failure err
      run()
