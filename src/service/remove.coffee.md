
# `service_remove(options, callback)`

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
require('mecano').service_start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, status){ /* do sth */ });
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service_remove", level: 'DEBUG', module: 'mecano/lib/service/remove'
      throw Error "Missing required option 'name'" unless options.name
      cacheonly = if options.cacheonly then '-C' else ''
      @execute
        cmd: """
        if ! rpm -qa --qf "%{NAME}\n" | grep -w '#{options.name}'; then exit 3; fi;
        yum remove -y #{cacheonly} '#{options.name}'
        """
        code_skipped: 3
      , (err, removed) ->
        throw Error "Invalid Service Name: #{options.name}" if err
        options.log if removed
        then message: "Service removed", level: 'WARN', module: 'mecano/lib/service/remove'
        else message: "Service already removed", level: 'INFO', module: 'mecano/lib/service/remove'
        
