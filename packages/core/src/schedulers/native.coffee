
utils = require '../utils'
{merge} = require 'mixme'

module.exports = (handlers, options = {}) ->
  scheduler = null
  # Managed handlers are resolved with the scheduler
  options.managed ?= false
  options.parallel ?= 1
  state =
    stack: []
    pause: if options.pause? then !!options.pause else false
    error: undefined
    output: []
    resolved: false
    running: 0
  promise = new Promise (resolve, reject) ->
    scheduler =
      state: state
      pump: ->
        return if state.pause
        return if state.running is options.parallel
        unless state.resolved
          if state.error
            state.resolved = true
            return reject state.error
          else unless state.stack.length
            state.resolved = true
            return resolve state.output
        return unless state.stack.length
        state.running++
        item = state.stack.shift()
        item = item
        setImmediate ->
          try
            result = await item.handler.call()
            state.running--
            item.resolve.call null, result
            # console.log options.managed, item.options.managed
            state.output.push result if item.options.managed
            setImmediate scheduler.pump
          catch error
            state.running--
            item.reject.call null, error
            state.error = error if item.options.managed
            setImmediate scheduler.pump
      unshift: (handlers, opts={}) ->
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        new Promise (resolve, reject) ->
          unless isArray
            state.stack.unshift
              handler: handlers
              resolve: resolve
              reject: reject
              options: merge options, opts
            scheduler.pump()
          else
            # Unshift from the last to the first element to preserve order
            Promise.all((
              scheduler.unshift handler, opts for handler in handlers.reverse()
            ).reverse()).then resolve, reject
      pause: ->
        state.pause = true
      resume: ->
        return unless state.pause
        state.pause = false
        scheduler.pump() if state.stack.length
      push: (handlers, opts={}) ->
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        prom = new Promise (resolve, reject) ->
          unless isArray
            state.stack.push
              handler: handlers
              resolve: resolve
              reject: reject
              options: merge options, opts
            scheduler.pump()
          else
            Promise.all(
              scheduler.push handler, opts for handler in handlers
            ).then resolve, reject
        prom.catch (->) # Handle strict unhandled rejections
        prom
    if handlers
      if handlers.length
        scheduler.push handlers, managed: true
      else
        resolve []
  promise.catch (->) # Handle strict unhandled rejections
  new Proxy promise, get: (target, name) ->
    if target[name]?
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    else
      scheduler[name]
