
utils = require '../utils'
{merge} = require 'mixme'

module.exports = (handlers, options = {}) ->
  scheduler = null
  # Managed handlers are resolved inside the scheduler promise. The promise
  # fullfil with an array which length is the number of managed handlers.
  # It is possible to defined `managed` globally for every handler and
  # individually for each handler when calling `push` or `unshift`.
  # By default, handlers passed in the scheduler creation are managed while
  # handler pushed or unshifted are not.
  # It is not possible to register managed handler once the scheduler has
  # resolved.
  options.managed ?= false
  options.parallel ?= 1
  state =
    stack: []
    pause: if options.pause? then !!options.pause else false
    error: undefined
    output: []
    resolved: false
    running: 0
  has_pending_tasks = ->
    pending = state.stack.some (task) ->
      task.options.managed
    pending
  clear_managed_tasks = ->
    state.stack = state.stack.filter (task) ->
      not task.options.managed
  promise = new Promise (resolve, reject) ->
    scheduler =
      state: state
      pump: ->
        return if state.pause
        return if state.running is options.parallel
        unless state.resolved
          if state.error
            state.resolved = true
            # Any pending managed task is stripped out after an error
            clear_managed_tasks()
            scheduler.pump()
            return reject state.error
          else unless has_pending_tasks()
            state.resolved = true
            scheduler.pump()
            return resolve state.output
        return unless state.stack.length
        state.running++
        item = state.stack.shift()
        # A managed handler cannot be scheduled once the scheduler resolves
        if item.options.managed and state.resolved
          throw utils.error 'SCHEDULER_RESOLVED', [
            'cannot execute a new handler,'
            'scheduler already in resolved state.'
          ]
        setImmediate ->
          try
            result = await item.handler.call()
            state.running--
            item.resolve.call null, result
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
