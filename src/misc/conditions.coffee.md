
# Conditions

Conditions are a set of properties you may add to the options of the Mecano
functions. They apply to all functions and control their execution.

For an action to be executed, all conditions must pass.

    module.exports = 

## Run an action for a user defined condition: `if`

Work on the property `if` in `options`.

When `if` is a boolean, a string, a number or null, its value determine the
output.

If it's a function, the arguments vary depending on the callback signature. With
1 argument, the argument is an options object and the handler is run
synchronously. With 2 arguments, the arguments are an options object plus a
callback and the handler is run asynchronously.

If it's an array, all its element must positively resolve for the condition to
pass.

Updating the content of a file if we are the owner

```js
mecano.render({
  source:'./file',
  if: function(options, callback){
    fs.stat(options.source, function(err, stat){
      # Render the file if we own it
      callback(err, stat.uid == process.getuid())
    });
  }
}, fonction(err, rendered){});
```

      if: (options, skip, succeed) ->
        # return succeed() if typeof options.if is 'undefined'
        options.if = [options.if] unless Array.isArray options.if
        ok = true
        each(options.if)
        .run (si, next) ->
          return next() unless ok
          # options.log? "Mecano `if`"
          type = typeof si
          if si is null or type is 'undefined'
            ok = false
            next()
          else if type is 'boolean' or type is 'number'
            ok = false unless si
            next()
          else if type is 'function'
            if si.length < 2
              try
                ok = false unless si options
                next()
              catch err then next err
            if si.length is 2
              si options, (err, is_ok) ->
                return next err if err
                ok = false unless is_ok
                next()
            else next new Error "Invalid callback"
          else if type is 'string'
            si = template si, options
            ok = false if si.length is 0
            next()
          else
            next new Error "Invalid condition type"
        .then (err) ->
          return skip err if err or not ok
          succeed()

## Run an action if false: `not_if`

Work on the property `not_if` in `options`.

When `if` is a boolean, a string, a number or null, its value determine the
output.

If it's a function, the arguments vary depending on the callback signature. With
1 argument, the argument is an options object and the handler is run
synchronously. With 2 arguments, the arguments are an options object plus a
callback and the handler is run asynchronously.

If it's an array, all its element must negatively resolve for the condition to
pass.

      not_if: (options, skip, succeed) ->
        # return succeed() if typeof options.not_if is 'undefined'
        options.not_if = [options.not_if] unless Array.isArray options.not_if
        ok = true
        each(options.not_if)
        .run (not_if, next) ->
          return next() unless ok
          # options.log? "Mecano `not_if`"
          type = typeof not_if
          if not_if is null or type is 'undefined'
            ok = true
            next()
          else if type is 'boolean' or type is 'number'
            ok = false if not_if
            next()
          else if type is 'function'
            # not_if options, next, ( -> ok = false; next arguments...)
            if not_if.length < 2
              try
                ok = false if not_if options
                next()
              catch err then next err
            if not_if.length is 2
              not_if options, (err, is_ok) ->
                return next err if err
                ok = false if is_ok
                next()
            else next new Error "Invalid callback"
          else if type is 'string'
            not_if = template not_if, options
            ok = false if not_if.length isnt 0
            next()
          else
            next new Error "Invalid condition type"
        .then (err) ->
          return skip err if err or not ok
          succeed()
  
## Run an action if a command succeed: `if_exec`

Work on the property `if_exec` in `options`. The value may 
be a single shell command or an array of commands.   

The callback `succeed` is called if all the provided command 
were executed successfully otherwise the callback `skip` is called.

      if_exec: (options, skip, succeed) ->
        # return succeed() unless options.if_exec?
        each(options.if_exec)
        .run (cmd, next) ->
          options.log? "Mecano `not_if_exec`: #{cmd}"
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
  
## Run an action unless a command succeed: `not_if_exec`

Work on the property `not_if_exec` in `options`. The value may 
be a single shell command or an array of commands.   

The callback `succeed` is called if all the provided command 
were executed with failure otherwise the callback `skip` is called.

      not_if_exec: (options, skip, succeed) ->
        # return succeed() unless options.not_if_exec?
        each(options.not_if_exec)
        .run (cmd, next) ->
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
  
## Run an action if a file exists: `if_exists`

Work on the property `if_exists` in `options`. The value may 
be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `destination`
option.

The callback `succeed` is called if all the provided paths 
exists otherwise the callback `skip` is called.

      if_exists: (options, skip, succeed) ->
        {ssh, if_exists, destination} = options
        if typeof not_if_exists is 'boolean' and destination
          if_exists = if if_exists then [destination] else null
        # return succeed() unless if_exists?
        each(if_exists)
        .run (if_exists, next) ->
          # options.log? "Mecano `if_exists`"
          fs.exists ssh, if_exists, (err, exists) ->
            if exists then next() else skip()
        .on 'end', succeed

## Skip an action if a file exists: `not_if_exists`

Work on the property `not_if_exists` in `options`. The value may 
be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `destination`
option.

The callback `succeed` is called if none of the provided paths 
exists otherwise the callback `skip` is called.

      not_if_exists: (options, skip, succeed) ->
        {ssh, not_if_exists, destination} = options
        if typeof not_if_exists is 'boolean' and destination
          not_if_exists = if not_if_exists then [destination] else null
        # return succeed() unless not_if_exists?
        each(not_if_exists)
        .run (not_if_exists, next) ->
          # options.log? "Mecano `not_if_exists`"
          fs.exists ssh, not_if_exists, (err, exists) ->
            if exists
            then next new Error
            else next()
        .on 'error', ->
          skip()
        .on 'end', succeed

## Ensure a file exist: `should_exist`

Ensure that an action run if all the files present in the 
option "should_exist" exist. The value may 
be a file path or an array of file paths.

The callback `succeed` is called if all of the provided paths 
exists otherwise the callback `skip` is called with an error.

      should_exist: (options, skip, succeed) ->
        # return succeed() unless options.should_exist?
        each(options.should_exist)
        .run (should_exist, next) ->
          # options.log? "Mecano `should_exist`"
          fs.exists options.ssh, should_exist, (err, exists) ->
            if exists
            then next()
            else next Error "File does not exist: #{should_exist}"
        # .then (err) -> if err then skip(err) else succeed()
        .on 'error', (err) ->
          skip err
        .on 'end', succeed

## Ensure a file already exist: `should_not_exist`

Ensure that an action run if none of the files present in the 
option "should_exist" exist. The value may 
be a file path or an array of file paths.

The callback `succeed` is called if none of the provided paths 
exists otherwise the callback `skip` is called with an error.

      should_not_exist: (options, skip, succeed) ->
        # return succeed() unless options.should_not_exist?
        each(options.should_not_exist)
        .run (should_not_exist, next) ->
          # options.log? "Mecano `should_not_exist`"
          fs.exists options.ssh, should_not_exist, (err, exists) ->
            if exists
            then next new Error "File does not exist: #{should_not_exist}"
            else next()
        .on 'error', (err) ->
          skip err
        .on 'end', ->
          succeed()

## Run all conditions: `all(options, skip, succeed)`

This is the function run internally to execute all the conditions.

*   `opts`
    Command options
*   `skip`
    Skip callback, called when a condition is not fulfill. May also be called with on error on failure
*   `succeed`
    Succeed callback, only called if all the condition succeed

Example:

```js
conditions.all({
  if: true
}, function(err){
  console.log('Conditins failed or pass an error')
}, function(){
  console.log('Conditions succeed')
})
```

      all: (options, failed, succeed) ->
        return succeed() unless options? and (typeof options is 'object' and not Array.isArray options)
        keys = Object.keys options
        i = 0
        next = ->
          key = keys[i++]
          return succeed() unless key?
          return next() unless module.exports[key]?
          module.exports[key] options, (err) ->
            options.log? "Mecano `#{key}`: skipping action"
            failed err
          , next
        next()


## Dependencies

    each = require 'each'
    misc = require './index'
    exec = require 'ssh2-exec'
    fs = require 'ssh2-fs'
    template = require './template'




