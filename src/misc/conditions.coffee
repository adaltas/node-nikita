
each = require 'each'
misc = require './index'
exec = require 'ssh2-exec'
fs = require 'ssh2-fs'

###
Conditionnal properties
=======================
###
conditions = module.exports = 
  ###

  `all(options, skip, succeed)` Run all conditions
  ---------------------------------------------------

  `opts`
  Command options

  `skip`
  Skip callback, called when a condition is not fulfill. May also be called with on error on failure

  `succeed`
  Succeed callback, only called if all the condition succeed

  ###
  all: (options, skip, succeed) ->
    # each([@if, @not_if, @if_exec, @not_if_exec, @if_exists, @not_if_exists, @should_exist])
    each(['if', 'not_if', 'if_exec', 'not_if_exec', 'if_exists', 'not_if_exists', 'should_exist'])
    .on 'item', (condition, next) ->
      return next() unless options[condition]?
      options.log? "Mecano #{condition}"
      conditions[condition] options, (->
        options.log? "Mecano `#{condition}`: skip"
        skip()
      ), (->
        options.log? "Mecano `#{condition}`: next"
        next()
      )
    .on('error', skip)
    .on('end', succeed)
  ###
  `if` Run an action for a user defined condition
  -----------------------------------------------

  Work on the property `if` in `options`. When `if` is a boolean, its value
  determine the output. If it's a function, the arguments vary depending on the
  callback signature. With 1 argument, the argument is a callback. With 2
  arguments, the arguments are the options and a callback. If it'a an array, all
  its element must positively resolve for the condition to pass.

  Updating the content of a file if we are the owner

      mecano.render
        source:'./file'
        if: (options, callback) ->
          fs.stat options.source, (err, stat) ->
            # Render the file if we own it
            callback err, stat.uid is process.getuid()

  ###
  if: (options, skip, succeed) ->
    return succeed() unless options.if?
    ok = true
    each(options.if)
    .on 'item', (si, next) ->
      return next() unless ok
      type = typeof si
      if type is 'boolean' or type is 'number'
        ok = false unless si
        next()
      else if type is 'function'
        if options.if.length is 1
          si (err, is_ok) ->
            return next err if err
            ok = false unless is_ok
            next()
        else if options.if.length is 2
          si options, (err, is_ok) ->
            return next err if err
            ok = false unless is_ok
            next()
        else if options.if.length is 3
          # Deprecated? should we continue to support this?
          si options, ( -> ok = false; next arguments...), next
        else next new Error "Invalid callback"
      else
        next new Error "Invalid condition type"
    .on 'both', (err) ->
      return skip err if err or not ok
      succeed()
  ###
  `not_if` Run an action if false
  -------------------------------

  Work on the property `not_if` in `options`. When `not_if` is a boolean, its
  value determine the output. If it's a function, the arguments vary depending
  on the callback signature. With 1 argument, the argument is a callback. With 2
  arguments, the arguments are the options and a callback. If it'a an array, all
  its element must positively resolve for the condition to pass.
  ###
  not_if: (options, skip, succeed) ->
    return succeed() unless options.not_if?
    ok = true
    each(options.not_if)
    .on 'item', (not_if, next) ->
      return next() unless ok
      type = typeof not_if
      if type is 'boolean' or type is 'number'
        ok = false if not_if
        next()
      else if type is 'function'
        # not_if options, next, ( -> ok = false; next arguments...)
        if options.not_if.length is 1
          not_if (err, is_ok) ->
            return next err if err
            ok = false if is_ok
            next()
        else if options.not_if.length is 2
          not_if options, (err, is_ok) ->
            return next err if err
            ok = false if is_ok
            next()
        else if options.not_if.length is 3
          # Deprecated? should we continue to support this?
          not_if options, next, ( -> ok = false; next arguments...)
        else next new Error "Invalid callback"
      else
        next new Error "Invalid condition type"
    .on 'both', (err) ->
      return skip err if err or not ok
      succeed()
  ###
  
  `if_exec` Run an action if a command is successfully executed
  -------------------------------------------------------------

  Work on the property `if_exec` in `options`. The value may 
  be a single shell command or an array of commands.   

  The callback `succeed` is called if all the provided command 
  were executed successfully otherwise the callback `skip` is called.

  ###
  if_exec: (options, skip, succeed) ->
    return succeed() unless options.if_exec?
    each(options.if_exec)
    .on 'item', (cmd, next) ->
      options.log? "Mecano `if_exec`: #{cmd}"
      options = { cmd: cmd, ssh: options.ssh }
      run = exec options
      if options.stdout
        run.stdout.pipe options.stdout, end: false
      if options.stderr
        run.stderr.pipe options.stderr, end: false
      run.on "exit", (code) ->
        options.log? "Mecano `if_exec`: code is \"#{code}\""
        if code is 0 then next() else skip()
    .on 'end', succeed
  ###
  
  `not_if_exec` Run an action unless a command is successfully executed
  ---------------------------------------------------------------------

  Work on the property `not_if_exec` in `options`. The value may 
  be a single shell command or an array of commands.   

  The callback `succeed` is called if all the provided command 
  were executed with failure otherwise the callback `skip` is called.

  ###
  not_if_exec: (options, skip, succeed) ->
    return succeed() unless options.not_if_exec?
    each(options.not_if_exec)
    .on 'item', (cmd, next) ->
      options.log? "Mecano `not_if_exec`: #{cmd}"
      options = { cmd: cmd, ssh: options.ssh }
      run = exec options
      if options.stdout
        run.stdout.pipe options.stdout, end: false
      if options.stderr
        run.stderr.pipe options.stderr, end: false
      run.on "exit", (code) ->
        options.log? "Mecano `not_if_exec`: code is \"#{code}\""
        if code is 0
        then next new Error
        else next()
    .on 'error', ->
      skip()
    .on 'end', succeed
  ###
  
  `if_exists` Run an action if a file exists
  ----------------------------------------

  Work on the property `if_exists` in `options`. The value may 
  be a file path or an array of file paths. You could also set the
  value to `true`, in which case it will be set with the `destination`
  option.

  The callback `succeed` is called if all the provided paths 
  exists otherwise the callback `skip` is called.

  ###
  if_exists: (options, skip, succeed) ->
    {ssh, if_exists, destination} = options
    if typeof not_if_exists is 'boolean' and destination
      if_exists = if if_exists then [destination] else null
    return succeed() unless if_exists?
    each(if_exists)
    .on 'item', (if_exists, next) ->
      fs.exists ssh, if_exists, (err, exists) ->
        if exists then next() else skip()
    .on 'end', succeed
  ###

  `not_if_exists` Skip an action if a file exists
  -----------------------------------------------

  Work on the property `not_if_exists` in `options`. The value may 
  be a file path or an array of file paths. You could also set the
  value to `true`, in which case it will be set with the `destination`
  option.

  The callback `succeed` is called if none of the provided paths 
  exists otherwise the callback `skip` is called.

  ###
  not_if_exists: (options, skip, succeed) ->
    {ssh, not_if_exists, destination} = options
    if typeof not_if_exists is 'boolean' and destination
      not_if_exists = if not_if_exists then [destination] else null
    return succeed() unless not_if_exists?
    each(not_if_exists)
    .on 'item', (not_if_exists, next) ->
      fs.exists ssh, not_if_exists, (err, exists) ->
        if exists
        then next new Error
        else next()
    .on 'error', ->
      skip()
    .on 'end', succeed
  ###

  `should_exist` Ensure a file exist
  ----------------------------------

  Ensure that an action run if all the files present in the 
  option "should_exist" exist. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if all of the provided paths 
  exists otherwise the callback `skip` is called with an error.

  ###
  should_exist: (options, skip, succeed) ->
    return succeed() unless options.should_exist?
    each(options.should_exist)
    .on 'item', (should_exist, next) ->
      fs.exists options.ssh, should_exist, (err, exists) ->
        if exists
        then next()
        else next new Error "File does not exist: #{should_exist}"
    .on 'error', (err) ->
      skip err
    .on 'end', succeed
  ###

  `should_not_exist` Ensure a file already exist
  ----------------------------------------------

  Ensure that an action run if none of the files present in the 
  option "should_exist" exist. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if none of the provided paths 
  exists otherwise the callback `skip` is called with an error.

  ###
  should_not_exist: (options, skip, succeed) ->
    return succeed() unless options.should_not_exist?
    each(options.should_not_exist)
    .on 'item', (should_not_exist, next) ->
      fs.exists options.ssh, should_not_exist, (err, exists) ->
        if exists
        then next new Error "File does not exist: #{should_not_exist}"
        else next()
    .on 'error', (err) ->
      skip err
    .on 'end', ->
      succeed()




