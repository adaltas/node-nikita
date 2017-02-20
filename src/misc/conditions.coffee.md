
# Conditions

Conditions are a set of properties you may add to the options of the Mecano
functions. They apply to all functions and control their execution.

A Mecano action will be executed if all the positive conditions are "true" and
none of the negative conditions are "true".

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
mecano.file.render({
  source:'./file',
  if: function(options, callback){
    fs.stat(options.source, function(err, stat){
      # Render the file if we own it
      callback(err, stat.uid == process.getuid())
    });
  }
}, fonction(err, rendered){});
```

      if: (options, succeed, skip) ->
        options.if = [options.if] unless Array.isArray options.if
        ok = true
        each(options.if)
        .call (si, next) =>
          return next() unless ok
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
                ok = false unless si.call @, options
                next()
              catch err then next err
            else if si.length is 2
              si.call @, options, (err, is_ok) ->
                return next err if err
                ok = false unless is_ok
                next()
            else next Error "Invalid argument length, expecting 2 or less, got #{si.length}"
          else if type is 'string' or (type is 'object' and Buffer.isBuffer si)
            si = template si.toString(), options
            ok = false if si.length is 0
            next()
          else
            next Error "Invalid condition \"if\": #{JSON.stringify si}"
        .then (err) ->
          if err or not ok then skip(err) else succeed()

## Run an action if false: `unless`

Work on the property `unless` in `options`.

When `if` is a boolean, a string, a number or null, its value determine the
output.

If it's a function, the arguments vary depending on the callback signature. With
1 argument, the argument is an options object and the handler is run
synchronously. With 2 arguments, the arguments are an options object plus a
callback and the handler is run asynchronously.

If it's an array, all its element must negatively resolve for the condition to
pass.

      unless: (options, succeed, skip) ->
        options.unless = [options.unless] unless Array.isArray options.unless
        ok = true
        each(options.unless)
        .call (not_if, next) =>
          return next() unless ok
          type = typeof not_if
          if not_if is null or type is 'undefined'
            ok = true
            next()
          else if type is 'boolean' or type is 'number'
            ok = false if not_if
            next()
          else if type is 'function'
            if not_if.length < 2
              try
                ok = false if not_if.call @, options
                next()
              catch err then next err
            else if not_if.length is 2
              not_if.call @, options, (err, is_ok) ->
                return next err if err
                ok = false if is_ok
                next()
            else next Error "Invalid callback"
          else if type is 'string' or (type is 'object' and Buffer.isBuffer not_if)
            not_if = template not_if.toString(), options
            ok = false if not_if.length isnt 0
            next()
          else
            next Error "Invalid condition \"unless\": #{JSON.stringify not_if}"
        .then (err) ->
          if err or not ok then skip(err) else succeed()

## Run an action if a command succeed: `if_exec`

Work on the property `if_exec` in `options`. The value may 
be a single shell command or an array of commands.   

The callback `succeed` is called if all the provided command 
were executed successfully otherwise the callback `skip` is called.

      if_exec: (options, succeed, skip) ->
        each(options.if_exec)
        .call (cmd, next) ->
          options.log? message: "Mecano `if_exec`: #{cmd}", level: 'DEBUG', module: 'mecano/misc/conditions'
          options = { cmd: cmd, ssh: options.ssh }
          run = exec options
          if options.stdout
            run.stdout.pipe options.stdout, end: false
          if options.stderr
            run.stderr.pipe options.stderr, end: false
          run.on "exit", (code) ->
            options.log? message: "Mecano `if_exec`: code is \"#{code}\"", level: 'INFO', module: 'mecano/misc/conditions'
            if code is 0 then next() else skip()
        .then succeed
  
## Run an action unless a command succeed: `unless_exec`

Work on the property `unless_exec` in `options`. The value may 
be a single shell command or an array of commands.   

The callback `succeed` is called if all the provided command 
were executed with failure otherwise the callback `skip` is called.

      unless_exec: (options, succeed, skip) ->
        each(options.unless_exec)
        .call (cmd, next) ->
          options.log? message: "Mecano `unless_exec`: #{cmd}", level: 'DEBUG', module: 'mecano/misc/conditions'
          options = { cmd: cmd, ssh: options.ssh }
          run = exec options
          if options.stdout
            run.stdout.pipe options.stdout, end: false
          if options.stderr
            run.stderr.pipe options.stderr, end: false
          run.on "exit", (code) ->
            options.log? message: "Mecano `unless_exec`: code is \"#{code}\"", level: 'INFO', module: 'mecano/misc/conditions'
            if code is 0 then skip() else next()
        .then succeed

## Run an action if a file exists: `if_exists`

Work on the property `if_exists` in `options`. The value may 
be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `target`
option.

The callback `succeed` is called if all the provided paths 
exists otherwise the callback `skip` is called.

      if_exists: (options, succeed, skip) ->
        {ssh, if_exists, target} = options
        if typeof if_exists is 'boolean' and target
          if_exists = if if_exists then [target] else null
        each(if_exists)
        .call (if_exists, next) ->
          fs.exists ssh, if_exists, (err, exists) ->
            if exists
              options.log? message: "File exists #{if_exists}, continuing", level: 'DEBUG', module: 'mecano/misc/conditions'
              next()
            else
              options.log? message: "File doesnt exists #{if_exists}, skipping", level: 'INFO', module: 'mecano/misc/conditions'
              skip()
        .then succeed

## Skip an action if a file exists: `unless_exists`

Work on the property `unless_exists` in `options`. The value may 
be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `target`
option.

The callback `succeed` is called if none of the provided paths 
exists otherwise the callback `skip` is called.

      unless_exists: (options, succeed, skip) ->
        {ssh, unless_exists, target} = options
        if typeof unless_exists is 'boolean' and target
          unless_exists = if unless_exists then [target] else null
        each(unless_exists)
        .call (unless_exists, next) ->
          fs.exists ssh, unless_exists, (err, exists) ->
            if exists
              options.log? message: "File exists #{unless_exists}, skipping", level: 'INFO', module: 'mecano/misc/conditions'
              skip()
            else
              options.log? message: "File doesnt exists #{unless_exists}, continuing", level: 'DEBUG', module: 'mecano/misc/conditions'
              next()
        .then succeed

## Ensure a file exist: `should_exist`

Ensure that an action run if all the files present in the 
option "should_exist" exist. The value may 
be a file path or an array of file paths.

The callback `succeed` is called if all of the provided paths 
exists otherwise the callback `skip` is called with an error.

      should_exist: (options, succeed, skip) ->
        # return succeed() unless options.should_exist?
        each(options.should_exist)
        .call (should_exist, next) ->
          fs.exists options.ssh, should_exist, (err, exists) ->
            if exists
            then next()
            else next Error "File does not exist: #{should_exist}"
        .error skip
        .then succeed

## Ensure a file already exist: `should_not_exist`

Ensure that an action run if none of the files present in the 
option "should_exist" exist. The value may 
be a file path or an array of file paths.

The callback `succeed` is called if none of the provided paths 
exists otherwise the callback `skip` is called with an error.

      should_not_exist: (options, succeed, skip) ->
        # return succeed() unless options.should_not_exist?
        each(options.should_not_exist)
        .call (should_not_exist, next) ->
          fs.exists options.ssh, should_not_exist, (err, exists) ->
            if exists
            then next Error "File does not exist: #{should_not_exist}"
            else next()
        .error skip
        .then -> succeed()

## Run all conditions: `all(options, skip, succeed)`

This is the function run internally to execute all the conditions.

*   `opts`
    Command options
*   `succeed`
    Succeed callback, only called if all the condition succeed
*   `skip`
    Skip callback, called when a condition is not fulfill. May also be called with on error on failure

Example:

```js
conditions.all({
  if: true
}, function(){
  console.log('Conditions succeed')
}, function(err){
  console.log('Conditins failed or pass an error')
})
```

      all: (context, options, succeed, failed) ->
        return succeed() unless options? and (typeof options is 'object' and not Array.isArray options)
        keys = Object.keys options
        i = 0
        next = ->
          key = keys[i++]
          return succeed() unless key?
          return next() if key is 'all'
          return next() unless module.exports[key]?
          module.exports[key].call context, options, next, (err) ->
            # options.log? "Mecano `#{key}`: skipping action"
            failed err
        next()

## Dependencies

    each = require 'each'
    exec = require 'ssh2-exec'
    fs = require 'ssh2-fs'
    template = require './template'
