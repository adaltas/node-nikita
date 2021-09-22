
utils = require '../utils'
{is_object_literal, merge} = require 'mixme'

module.exports = (tasks, options = {}) ->
  scheduler = null
  # Managed tasks are resolved inside the scheduler promise. The promise
  # fulfill with an array which length is the number of managed tasks.
  # It is possible to defined `managed` globally for every handler and
  # individually for each handler when calling `push` or `unshift`.
  # By default, tasks passed in the scheduler creation are managed while
  # handler pushed or unshifted are not.
  # It is not possible to register managed handler once the scheduler has
  # resolved.
  options.managed ?= !!tasks
  options.parallel ?= 1
  options.parallel = 1 if options.parallel is false
  options.parallel = -1 if options.parallel is true
  options.end ?= true
  state =
    stack: []
    pause: if options.pause? then !!options.pause else false
    error: undefined
    output: []
    resolved: 0
    fulfilled: 0
    rejected: 0
    pending: 0
    managed:
      running: 0
      resolved: false
    running: 0
  count_pending_tasks = ->
    state.stack.filter (task) ->
      task.managed
    .length
  clear_managed_tasks = ->
    state.stack = state.stack.filter (task) ->
      not task.managed
  promise = new Promise (resolve, reject) ->
    scheduler =
      state: state
      end: (end) ->
        options.end = end
        scheduler.pump()
      pump: ->
        return if state.pause
        return if state.running is options.parallel
        if not state.managed.resolved
          if state.managed.error
            state.managed.resolved = true
            # Any pending managed task is stripped out after an error
            clear_managed_tasks()
            scheduler.pump()
            return reject state.managed.error
          else if options.managed and options.end and count_pending_tasks() + state.managed.running is 0
            state.managed.resolved = true
            scheduler.pump()
            return resolve state.output
          else if not options.managed and options.end and state.stack.length is 0
            state.managed.resolved = true
            return resolve()
        return unless state.stack.length
        task = state.stack.shift()
        if options.strict is true and not task.managed and state.error
          task.reject state.error
          setImmediate scheduler.pump
          return
        state.running++
        state.pending--
        state.managed.running++ if task.managed
        # A managed handler cannot be scheduled once the scheduler resolves
        if task.managed and state.managed.resolved
          throw utils.error 'SCHEDULER_RESOLVED', [
            'cannot execute a new handler,'
            'scheduler already in resolved state.'
          ]
        setImmediate ->
          try
            result = await task.handler.call()
            state.running--
            state.managed.running-- if task.managed
            state.fulfilled++
            state.resolved++
            task.resolve.call null, result
            state.output.push result if task.managed
            setImmediate scheduler.pump
          catch error
            state.running--
            state.managed.running-- if task.managed
            state.rejected++
            state.resolved++
            task.reject.call null, error
            state.error = error if options.strict
            state.managed.error = error if task.managed
            setImmediate scheduler.pump
      unshift: (tasks) ->
        isArray = Array.isArray tasks
        tasks = handler: tasks if not isArray and typeof tasks is 'function'
        throw Error 'Invalid Argument' unless isArray or is_object_literal tasks
        new Promise (resolve, reject) ->
          unless isArray
            state.pending++
            tasks.managed ?= options.managed
            state.stack.unshift {
              ...tasks
              resolve: resolve
              reject: reject
            }
            scheduler.pump()
          else
            # Unshift from the last to the first element to preserve order
            Promise.all((
              scheduler.unshift task for task in tasks.reverse()
            ).reverse()).then resolve, reject
      pause: ->
        state.pause = true
      broadcast: (err, result) ->
        # this is a terrible hack, see session/plugins/on_normalize
        # for a test illustrating it when an error is thrown in parent
        # and children are still registered for execution
        options.strict = true # and not task.managed and state.error
        state.pause = false
        state.error = err
        scheduler.pump() if state.stack.length
      resume: ->
        return unless state.pause
        state.pause = false
        scheduler.pump() if state.stack.length
      push: (tasks) ->
        isArray = Array.isArray tasks
        tasks = handler: tasks if not isArray and typeof tasks is 'function'
        throw Error 'Invalid Argument' unless isArray or is_object_literal tasks
        prom = new Promise (resolve, reject) ->
          unless isArray
            state.pending++
            tasks.managed ?= options.managed
            state.stack.push {
              ...tasks
              resolve: resolve
              reject: reject
            }
            scheduler.pump()
          else
            Promise.all(
              scheduler.push task for task in tasks
            ).then resolve, reject
        prom.catch (->) # Handle strict unhandled rejections
        prom
    if tasks
      if tasks.length
        scheduler.push tasks.map (task) ->
          task = handler: task if typeof task is 'function'
          {managed: true, ...task}
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
