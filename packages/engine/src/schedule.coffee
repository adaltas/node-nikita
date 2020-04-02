
error = require './utils/error'

module.exports = ->
  stack = []
  running = false
  events =
    end: []
  scheduler =
    on_end: (fn) ->
      events.end.push fn
      @
    pump: ->
      return if running
      running = true
      if stack.length
        [handler, resolve, reject] = @next()
        res = handler.call()
        if Array.isArray res
          running = false
          handlers = res
          # stack.unshift handler for handler in handlers
          promises = for handler in handlers.reverse()
            new Promise (resolve, reject) ->
              stack.unshift [handler, resolve, reject]
          Promise.all promises.reverse()
          .then resolve, reject
          setImmediate ->
            scheduler.pump()
          # handlers.map stack.unshift
        else if res.then
          res.then ->
            running = false
            resolve.apply handler, arguments
            setImmediate ->
              scheduler.pump()
          , (err) ->
            running = false
            handler.call() for handler in events.end
            reject err
        else
          throw error 'SCHEDULER_INVALID_HANDLER', [
            'scheduled handler must return a promise or an array of handlers,'
            "got #{JSON.stringify res}"
          ]
      else
        handler.call() for handler in events.end
    next: ->
      stack.shift()
    add: (handler) ->
      prom = new Promise (resolve, reject) ->
        stack.push [handler, resolve, reject]
        # Pump execution
        setImmediate ->
          scheduler.pump()
      prom
