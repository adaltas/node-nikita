
# Conditions

Conditions are a set of properties you may add to the options of the Nikita
functions. They apply to all functions and control their execution.

A Nikita action will be executed if all the positive conditions are "true" and
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
nikita.file.render({
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
        .next (err) ->
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
        .next (err) ->
          if err or not ok then skip(err) else succeed()

## Run an action if a command succeed: `if_exec`

Work on the property `if_exec` in `options`. The value may 
be a single shell command or an array of commands.   

The callback `succeed` is called if all the provided command 
were executed successfully otherwise the callback `skip` is called.

      if_exec: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        each(options.if_exec)
        .call (cmd, next) =>
          @log message: "Nikita `if_exec`: #{cmd}", level: 'DEBUG', module: 'nikita/misc/conditions'
          run = exec ssh: ssh, cmd: cmd
          # if options.stdout
          #   run.stdout.pipe options.stdout, end: false
          # if options.stderr
          #   run.stderr.pipe options.stderr, end: false
          run.on "exit", (code) =>
            @log message: "Nikita `if_exec`: code is \"#{code}\"", level: 'INFO', module: 'nikita/misc/conditions'
            if code is 0 then next() else skip()
        .next succeed

## Run an action unless a command succeed: `unless_exec`

Work on the property `unless_exec` in `options`. The value may 
be a single shell command or an array of commands.   

The callback `succeed` is called if all the provided command 
were executed with failure otherwise the callback `skip` is called.

      unless_exec: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        each(options.unless_exec)
        .call (cmd, next) =>
          @log message: "Nikita `unless_exec`: #{cmd}", level: 'DEBUG', module: 'nikita/misc/conditions'
          run = exec ssh: ssh, cmd: cmd
          # if options.stdout
          #   run.stdout.pipe options.stdout, end: false
          # if options.stderr
          #   run.stderr.pipe options.stderr, end: false
          run.on "exit", (code) =>
            @log message: "Nikita `unless_exec`: code is \"#{code}\"", level: 'INFO', module: 'nikita/misc/conditions'
            if code is 0 then skip() else next()
        .next succeed

## Run an action if OS match: `if_os`

Work on the property `if_os` in `options`. The value may 
be a single condition command or an array of conditions.   

The callback `succeed` is called if any of the provided filter passed otherwise
the callback `skip` is called.

      if_os: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        options.if_os = [options.if_os] unless Array.isArray options.if_os
        for rule in options.if_os
          rule.name ?= []
          rule.name = [rule.name] unless Array.isArray rule.name
          rule.version ?= []
          rule.version = [rule.version] unless Array.isArray rule.version
          rule.version = semver.sanitize rule.version, 'x'
          rule.arch ?= []
          rule.arch = [rule.arch] unless Array.isArray rule.arch
        @log message: "Nikita `if_os`: #{JSON.stringify options.if_os}", level: 'DEBUG', module: 'nikita/misc/conditions'
        exec ssh, os, (err, stdout, stderr) ->
          return skip err if err
          [arch, name, version] = stdout.split '|'
          name = 'redhat' if name.toLowerCase() is 'red hat'
          # Remove minor version (eg centos 7)
          version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec version
          match = options.if_os.some (rule) ->
            n = !rule.name.length || rule.name.some (value) ->
              return true if typeof value is 'string' and value is name
              return true if value instanceof RegExp and value.test name
            v = !rule.version.length || rule.version.some (value) ->
              version = semver.sanitize version, '0'
              return true if typeof value is 'string' and semver.satisfies version, value
              return true if value instanceof RegExp and value.test version
            return n and v
          if match then succeed() else skip()

## Run an action unless OS match: `unless_os`

Work on the property `unless_os` in `options`. The value may 
be a single condition command or an array of conditions.   

The callback `succeed` is called if none of the provided filter passed otherwise
the callback `skip` is called.

      unless_os: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        options.unless_os = [options.unless_os] unless Array.isArray options.unless_os
        for rule in options.unless_os
          rule.name ?= []
          rule.name = [rule.name] unless Array.isArray rule.name
          rule.version ?= []
          rule.version = [rule.version] unless Array.isArray rule.version
          rule.version = semver.sanitize rule.version, 'x'
          rule.arch ?= []
          rule.arch = [rule.arch] unless Array.isArray rule.arch
        @log message: "Nikita `unless_os`: #{JSON.stringify options.unless_os}", level: 'DEBUG', module: 'nikita/misc/conditions'
        exec ssh, os, (err, stdout, stderr) ->
          return skip err if err
          [arch, name, version] = stdout.split '|'
          name = 'redhat' if name.toLowerCase() is 'red hat'
          # Remove minor version (eg centos 7)
          version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec version
          match = options.unless_os.some (rule) ->
            n = !rule.name.length || rule.name.some (value) ->
              return true if typeof value is 'string' and value is name
              return true if value instanceof RegExp and value.test name
            v = !rule.version.length || rule.version.some (value) ->
              version = semver.sanitize version, '0'
              return true if typeof value is 'string' and semver.satisfies version, value
              return true if value instanceof RegExp and value.test version
            return n and v
          if match then skip() else succeed()

## Run an action if a file exists: `if_exists`

Work on the property `if_exists` in `options`. The value may 
be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `target`
option.

The callback `succeed` is called if all the provided paths 
exists otherwise the callback `skip` is called.

      if_exists: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        if typeof options.if_exists is 'boolean' and options.target
          options.if_exists = if options.if_exists then [options.target] else null
        each(options.if_exists)
        .call (if_exists, next) =>
          fs.exists ssh, if_exists, (err, exists) =>
            if exists
              @log message: "File exists #{if_exists}, continuing", level: 'DEBUG', module: 'nikita/misc/conditions'
              next()
            else
              @log message: "File doesnt exists #{if_exists}, skipping", level: 'INFO', module: 'nikita/misc/conditions'
              skip()
        .next succeed

## Skip an action if a file exists: `unless_exists`

Work on the property `unless_exists` in `options`. The value may 
be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `target`
option.

The callback `succeed` is called if none of the provided paths 
exists otherwise the callback `skip` is called.

      unless_exists: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        if typeof options.unless_exists is 'boolean' and options.target
          options.unless_exists = if options.unless_exists then [options.target] else null
        each(options.unless_exists)
        .call (unless_exists, next) =>
          fs.exists ssh, unless_exists, (err, exists) =>
            if exists
              @log message: "File exists #{unless_exists}, skipping", level: 'INFO', module: 'nikita/misc/conditions'
              skip()
            else
              @log message: "File doesnt exists #{unless_exists}, continuing", level: 'DEBUG', module: 'nikita/misc/conditions'
              next()
        .next succeed

## Ensure a file exist: `should_exist`

Ensure that an action run if all the files present in the 
option "should_exist" exist. The value may 
be a file path or an array of file paths.

The callback `succeed` is called if all of the provided paths 
exists otherwise the callback `skip` is called with an error.

      should_exist: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        each(options.should_exist)
        .call (should_exist, next) ->
          fs.exists ssh, should_exist, (err, exists) ->
            if exists
            then next()
            else next Error "File does not exist: #{should_exist}"
        .error skip
        .next succeed

## Ensure a file already exist: `should_not_exist`

Ensure that an action run if none of the files present in the 
option "should_exist" exist. The value may 
be a file path or an array of file paths.

The callback `succeed` is called if none of the provided paths 
exists otherwise the callback `skip` is called with an error.

      should_not_exist: (options, succeed, skip) ->
        # SSH connection
        ssh = @ssh options.ssh
        each(options.should_not_exist)
        .call (should_not_exist, next) ->
          fs.exists ssh, should_not_exist, (err, exists) ->
            if exists
            then next Error "File does not exist: #{should_not_exist}"
            else next()
        .error skip
        .next -> succeed()

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
  console.info('Conditions succeed')
}, function(err){
  console.info('Conditins failed or pass an error')
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
            # @log "Nikita `#{key}`: skipping action"
            failed err
        next()
        null

## Dependencies

    each = require 'each'
    exec = require 'ssh2-exec'
    fs = require 'ssh2-fs'
    os = require './os'
    semver = require './semver'
    template = require './template'
