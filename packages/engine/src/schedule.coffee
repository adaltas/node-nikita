

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
      if @has_next()
        [fn, resolve, reject] = @next()
        res = fn.call()
        res.then ->
          running = false
          resolve.apply fn, arguments
          setImmediate ->
            scheduler.pump()
        , (err) ->
          running = false
          fn.call() for fn in events.end
          reject err
      else
        fn.call() for fn in events.end
    has_next: ->
      stack.length
    next: ->
      stack.shift()
    add: (fn) ->
      prom = new Promise (resolve, reject) ->
        stack.push [fn, resolve, reject]
        # Pump execution
        setImmediate ->
          scheduler.pump()
      prom
