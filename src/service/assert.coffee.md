
# `nikita.service`

Assert service information and status.

The option "action" takes 3 possible values: "start", "stop" and "restart". A 
service will only be restarted if it leads to a change of status. Set the value 
to "['start', 'restart']" to ensure the service will be always started.

## Options

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any
  provided string, require the "rootdir" option if activated.
* `name` (string)   
  Package name, required.
* `srv_name` (string)   
  Name used by the service utility, default to "name".
* `installed`   
  Assert the package is installeds.
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if
  the "arch_chroot" option is activated.

## Source Code

    module.exports = (options) ->
      @log message: "Entering service.install", level: 'DEBUG', module: 'nikita/lib/service/install'
      # Options
      options.name ?= options.argument if typeof options.argument is 'string'
      options.srv_name ?= options.name
      options.name = [options.name] if typeof options.name is 'string'
      # Validation
      throw Error "Invalid Name: #{JSON.stringify options.name}" unless options.name

### Assert a Package is installed

      @system.execute
        if: options.installed?
        cmd: """
        if command -v yum >/dev/null 2>&1; then
          rpm -qa --qf "%{NAME}\n" | grep '^#{options.name.join '|'}$'
        elif command -v pacman >/dev/null 2>&1; then
          pacman -Qqe | grep '^#{options.name.join '|'}$'
        elif command -v apt-get >/dev/null 2>&1; then
          dpkg -l | grep \'^ii\' | awk \'{print $2}\' | grep '^#{options.name.join '|'}$'
        else
          echo "Unsupported Package Manager" >&2
          exit 2
        fi
        """
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
        stdin_log: true
        stdout_log: false
        shy: true
      , (err) ->
        throw Error "Unsupported Package Manager" if err?.code is 2
        throw Error "Uninstalled Package: #{options.name}" if err

### Assert a Service is started or stopped

Note, this doesnt check wether a service is installed or not.
        
      @system.execute
        if: options.started? or options.stopped?
        cmd: """
          ls \
            /lib/systemd/system/*.service \
            /etc/systemd/system/*.service \
            /etc/rc.d/* \
            /etc/init.d/* \
            2>/dev/null \
          | grep -w "#{options.srv_name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status #{options.srv_name} || exit 3
          elif command -v service >/dev/null 2>&1; then
            service #{options.srv_name} status || exit 3
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
          """
        code: 0
        code_skipped: 3
        arch_chroot: options.arch_chroot
        rootdir: options.rootdir
      , (err, {status}) ->
        throw Error "Unsupported Loader" if err?.code is 2
        return if err
        if options.started?
          throw Error "Service Not Started: #{options.srv_name}" if options.started and not status
          throw Error "Service Started: #{options.srv_name}" if not options.started and status
        if options.stopped?
          throw Error "Service Not Stopped: #{options.srv_name}" if options.stopped and status
          throw Error "Service Stopped: #{options.srv_name}" if not options.stopped and not status
