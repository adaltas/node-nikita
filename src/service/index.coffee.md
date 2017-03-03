
# `nikita.service(options, [callback])`

Install a service. For now, only yum over SSH.

## Options

*   `cacheonly` (boolean)   
    Run the yum command entirely from system cache, don't update cache.   
*   `name` (string)   
    Package name, optional.   
*   `startup`   
    Run service daemon on startup. If true, startup will be set to '2345', use
    an empty string to not define any run level.   
*   `yum_name` (string)   
    Name used by the yum utility, default to "name".   
*   `chk_name` (string)   
    Name used by the chkconfig utility, default to "srv_name" and "name".   
*   `srv_name` (string)   
    Name used by the service utility, default to "name".   
*   `cache`   
    Run entirely from system cache to list installed and outdated packages.   
*   `action`   
    Execute the service with the provided action argument.   
*   `installed`   
    Cache a list of installed services. If an object, the service will be
    installed if a key of the same name exists; if anything else (default), no
    caching will take place.   
*   `updates`   
    Cache a list of outdated services. If an object, the service will be updated
    if a key of the same name exists; If true, the option will be converted to
    an object with all the outdated service names as keys; if anything else
    (default), no caching will take place.   
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
*   `status`   
    Indicate a change in service such as a change in installation, update, 
    start/stop or startup registration.   
*   `installed`   
    List of installed services.   
*   `updates`   
    List of services to update.   

## Example

```js
require('nikita').service([{
  ssh: ssh,
  name: 'ganglia-gmetad-3.5.0-99',
  srv_name: 'gmetad',
  action: 'stop',
  startup: false
},{
  ssh: ssh,
  name: 'ganglia-web-3.5.7-99'
}], function(err, installed){
  console.log(err ? err.message : 'Service installed: ' + !!installed);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering service", level: 'DEBUG', module: 'nikita/lib/service'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      pkgname = options.yum_name or options.name
      chkname = options.chk_name or options.srv_name or options.name
      srvname = options.srv_name or options.chk_name or options.name
      options.action = options.action.split(',') if typeof options.action is 'string'
      # discover Os and Version
      # check /etc/system-release for redhat and centos
      # Todo: Check /etc/issue for ubuntu
      options.store ?= {}
      @service.install
        name: pkgname
        cache: options.cache
        cacheonly: options.cacheonly
        if: pkgname # option name and yum_name are optional, skill installation if not present
      @service.startup
        name: chkname
        startup: options.startup
        if: options.startup?
      @call 
        if: -> options.action
      , ->
        @service.status
          name: srvname
          code_started: options.code_started
          code_stopped: options.code_stopped
          shy: true
        @service.start
          name: srvname
          if: -> not @status(-1) and 'start' in options.action
        @service.stop
          name: srvname
          if: -> @status(-2) and 'stop' in options.action
        @service.restart
          name: srvname
          if: -> @status(-3) and 'restart' in options.action

## Further Reading

*   [service in linux](https://www.digitalocean.com/community/tutorials/how-to-configure-a-linux-service-to-start-automatically-after-a-crash-or-reboot-part-2-reference#systemd-configuration-files-unit-files)
*   [systemd vs sysvinit](https://fedoraproject.org/wiki/SysVinit_to_Systemd_Cheatsheet)
