"use strict"

{merge} = require 'mixme'

module.exports = ->
  'nikita:session:normalize': (action, handler) ->
    # Move property from action to metadata
    for property in ['attempt', 'sleep', 'retry']
      if action.hasOwnProperty property
        action.metadata ?= {}
        action.metadata[property] = action[property]
        delete action[property]
    handler
  'nikita:session:action': (action) ->
    action.metadata.attempt ?= 0
    action.metadata.retry ?= 1
    action.metadata.sleep ?= 3000
  'nikita:session:handler:call': ({}, handler) ->
    ({action}) ->
      args = arguments
      {retry} = action.metadata
      options = merge {}, action.options
      # Handle error
      error = (err) ->
        throw err if retry isnt true and action.metadata.attempt >= retry - 1
        # Increment the attempt metadata
        action.metadata.attempt++
        action.options = merge {}, options
        # Reschedule
        run()
      run = ->
        try
          output = handler.call @, ...args
          if output and output.then
            output.catch error
          else
            output
        catch err then error err
      run()
