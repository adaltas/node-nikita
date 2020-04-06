
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
          scheduler.add(handlers).then resolve, reject
          setImmediate ->
            scheduler.pump()
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
    add: (handlers, options={}) ->
      prom = new Promise (resolve, reject) ->
        dir = if options.first then 'unshift' else 'push'
        unless Array.isArray handlers
          stack[dir] [handlers, resolve, reject]
        else
          promises = for handler in handlers
            new Promise (resolve, reject) ->
              stack[dir] [handler, resolve, reject]
          Promise.all(promises).then resolve, reject
        # Pump execution
        setImmediate ->
          running = false if options.force
          scheduler.pump()
      prom
