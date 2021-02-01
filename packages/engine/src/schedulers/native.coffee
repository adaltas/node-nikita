
utils = require '../utils'

module.exports = (handlers) ->
  stack = []
  scheduler = null
  state =
    error: undefined
    output: []
    resolved: false
    running: false
  promise = new Promise (resolve, reject) ->
    scheduler =
      pump: ->
        return if state.running
        unless state.resolved
          if state.error
            state.resolved = true
            return reject state.error
          else unless stack.length
            state.resolved = true
            return resolve state.output
        return unless stack.length
        state.running = true
        item = stack.shift()
        item = item
        setImmediate ->
          try
            result = await item.handler.call()
            state.running = false
            item.resolve.call null, result
            state.output.push result if item.options.output
            setImmediate -> scheduler.pump()
          catch error
            state.running = false
            item.reject.call null, error
            state.error = error unless stack.length is 0
            setImmediate -> scheduler.pump()
      unshift: (handlers, options={}) ->
        options.pump ?= true
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        new Promise (resolve, reject) ->
          unless isArray
            stack.unshift
              handler: handlers
              resolve: resolve
              reject: reject
              options: options
            scheduler.pump()
          else
            # Unshift from the last to the first element to preserve order
            Promise.all((
              scheduler.unshift handler, pump: false for handler in handlers.reverse()
            ).reverse()).then resolve, reject
      push: (handlers, options={}) ->
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        prom = new Promise (resolve, reject) ->
          unless isArray
            stack.push
              handler: handlers
              resolve: resolve
              reject: reject
              options: options
            scheduler.pump()
          else
            Promise.all(
              scheduler.push handler, options for handler in handlers
            ).then resolve, reject
        prom.catch (->) # Handle strict unhandled rejections
        prom
    scheduler.push handlers, output: true if handlers
  promise.catch (->) # Handle strict unhandled rejections
  new Proxy promise, get: (target, name) ->
    if target[name]?
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    else
      scheduler[name]
