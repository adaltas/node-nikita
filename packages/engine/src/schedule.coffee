
error = require './utils/error'

module.exports = ->
  stack = []
  running = false
  events =
    end: []
  scheduler =
    on_end: (resolve, reject) ->
      events.end.push resolve: resolve, reject: reject
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
            reject err
            setImmediate ->
              for prom in events.end
                {reject} = prom
                reject.call()
        else
          throw error 'SCHEDULER_INVALID_HANDLER', [
            'scheduled handler must return a promise or an array of handlers,'
            "got #{JSON.stringify res}"
          ]
      else
        for prom in events.end
          {resolve} = prom
          resolve.call()
    next: ->
      stack.shift()
    clear: ->
      stack = []
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
