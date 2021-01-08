
utils = require '../utils'

module.exports = ->
  stack = []
  running = false
  scheduler = null
  promise = new Promise (fresolve, freject) ->
    scheduler =
      pump: ->
        return if running
        return fresolve() unless stack.length
        running = true
        [handler, resolve, reject] = stack.shift()
        setImmediate ->
          res = handler.call()
          if res?.then
            res.then ->
              running = false
              resolve.apply null, arguments
              setImmediate -> scheduler.pump()
            , ->
              running = false
              reject.apply null, arguments
              setImmediate -> scheduler.pump()
          else if Array.isArray res
            running = false
            scheduler.unshift(res).then resolve, reject
          else if res
            throw Error "Invalid state #{JSON.stringify res}"
      unshift: (handlers, {pump=true}={}) ->
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        new Promise (resolve, reject) ->
          unless isArray
            stack.unshift [handlers, resolve, reject]
            scheduler.pump() if pump
          else
            # Unshift from the last to the first element to preservce order
            Promise.all((
              scheduler.unshift handler, pump: false for handler in handlers.reverse()
            ).reverse()).then resolve, reject
            scheduler.pump() if pump
      push: (handlers) ->
        isArray = Array.isArray handlers
        throw Error 'Invalid Argument' unless isArray or typeof handlers is 'function'
        new Promise (resolve, reject) ->
          unless isArray
            stack.push [handlers, resolve, reject]
            scheduler.pump()
          else
            Promise.all(
              scheduler.push handler for handler in handlers
            ).then resolve, reject
  new Proxy promise, get: (target, name) ->
    if target[name]?
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    else
      scheduler[name]
