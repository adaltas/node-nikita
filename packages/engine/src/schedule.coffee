

module.exports = ->
  stack = []
  running = false
  events =
    end: []
  on_end: (fn) ->
    events.end.push fn
    @
  pump: ->
    return if running
    running = true
    if fn = @next()
      fn.call()
      .catch (err) ->
        running = false
        throw err
      .then =>
        running = false
        setImmediate =>
          @pump()
    else
      for fn in events.end
        fn.call()
  next: ->
    stack.shift()
  add: (fn) ->
    stack.push fn
    # Pump execution
    setImmediate =>
      @pump()
    fn
