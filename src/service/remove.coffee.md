
# `mecano.service.remove(options, [callback])`

Status of a service.

## Options

*   `cacheonly` (boolean)   
    Run the yum command entirely from system cache, don't update cache.   
*   `name` (string)   
    Service name.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Indicates if the startup behavior has changed.   

## Example

```js
require('mecano').service.start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service.remove", level: 'DEBUG', module: 'mecano/lib/service/remove'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      options.manager ?= options.store['mecano:service:manager']
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name
      # Action
      options.log message: "Remove service #{options.name}", level: 'INFO', module: 'mecano/lib/service/remove'
      cacheonly = if options.cacheonly then '-C' else ''
      @system.execute
        cmd: """
        if which yum >/dev/null; then exit 1; fi
        if which apt-get >/dev/null; then exit 2; fi
        """
        code: [1, 2]
        unless: options.manager
        relax: true
        shy: true
      , (err, status, stdout, stderr, signal) ->
        throw err if err
        options.manager = switch signal
          when 1 then 'yum'
          when 2 then 'apt'
        options.store['mecano:service:manager'] = options.manager if options.cache
      @system.execute
        cmd: -> switch options.manager
          when 'yum' then """
            if ! rpm -qa --qf "%{NAME}\n" | grep -w '#{options.name}'; then exit 3; fi;
            yum remove -y #{cacheonly} '#{options.name}'
            """
          when 'apt' then """
          if ! dpkg -l | grep \'^ii\' | awk \'{print $2}\' | grep -w '#{options.name}'; then exit 3; fi;
          apt-get remove -y #{cacheonly} '#{options.name}'
          """
        code_skipped: 3
      , (err, removed) ->
        throw Error "Invalid Service Name: #{options.name}" if err
        options.log if removed
        then message: "Service removed", level: 'WARN', module: 'mecano/lib/service/remove'
        else message: "Service already removed", level: 'INFO', module: 'mecano/lib/service/remove'
        
