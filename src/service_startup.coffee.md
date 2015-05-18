
# `service_startup(options, callback)` 

Activate or desactivate a service on startup.

## Options

*   `name` (string)   
    Service name, required.   
*   `startup` (boolean|string)   
    Run service daemon on startup, required. A string represent a list of activated
    levels, for example '2345'.   
    an empty string to not define any run level.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Indicates if the startup behavior has changed.   

## Example

```js
require('mecano').service_startup([{
  ssh: ssh,
  name: 'gmetad',
  startup: false
}, function(err, modified){ /* do sth */ });
```

## Source Code

    module.exports = (options, callback) ->
      return callback new Error "Missing required option 'name'" unless options.name
      return callback new Error "Missing required option 'startup'" unless options.startup?
      modified = false
      do_startuped = =>
        @execute
          cmd: "chkconfig --list #{options.name}"
          code_skipped: 1
        , (err, registered, stdout, stderr) ->
          return callback err if err
          # Invalid service name return code is 0 and message in stderr start by error
          if /^error/.test stderr
            options.log? "Mecano `service_startup`: Invalid chkconfig name for `#{options.name}` [ERROR]"
            return callback new Error "Invalid chkconfig name for `#{options.name}`"
          current_startup = ''
          if registered
            for c in stdout.split(' ').pop().trim().split '\t'
              [level, status] = c.split ':'
              current_startup += level if ['on', 'marche'].indexOf(status) > -1
          return do_end() if options.startup is true and current_startup.length
          return do_end() if options.startup is current_startup
          return do_end() if registered and options.startup is false and current_startup is ''
          modified = true
          if options.startup
          then startup_add()
          else startup_del()
      startup_add = =>
        cmd = "chkconfig --add #{options.name};"
        if typeof options.startup is 'string'
          startup_on = startup_off = ''
          for i in [0...6]
            if options.startup.indexOf(i) isnt -1
            then startup_on += i
            else startup_off += i
          cmd += "chkconfig --level #{startup_on} #{options.name} on;" if startup_on
          cmd += "chkconfig --level #{startup_off} #{options.name} off;" if startup_off
        else
          cmd += "chkconfig #{options.name} on;"
        @execute
          cmd: cmd
        , (err) ->
          return callback err if err
          options.log? "Mecano `service_startup`: #{options.name} on [INFO]"
          do_end()
      startup_del = =>
        options.log? "Mecano `service_startup`: startup off"
        # Setting the level to off. An alternative is to delete it: `chkconfig --del #{options.name}`
        @execute
          cmd: "chkconfig #{options.name} off"
        , (err) ->
          return callback err if err
          options.log? "Mecano `service_startup`: #{options.name} off [INFO]"
          do_end()
      do_end = ->
        options.log? "Mecano `service_startup`: #{options.name} not modified [DEBUG]" unless modified
        callback null, modified
      do_startuped()



