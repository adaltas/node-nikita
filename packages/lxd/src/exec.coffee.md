
# `nikita.lxd.exec`

Push files into containers.

## Options

* `name` (string, required)   
  The name of the container.
* `cmd` (string, required)   
  The command to execute.

## Example

```
require('nikita')
.lxd.exec({
  name: "my-container"
  cmd: "whoami"
}, function(err, {status, stdout, stderr}) {
  console.log( err ? err.message : stdout)
});

```

## Todo

* Support `env` option

## Source Code

    module.exports =  ({options}, callback) ->
      @log message: "Entering lxd.exec", level: 'DEBUG', module: '@nikitajs/lxd/lib/exec'
      throw Error "Invalid Option: name is required" unless options.name
      @system.execute options, trap: false,
        cmd: [
          "cat <<'EOF' | lxc exec #{options.name} -- bash"
          'set -e' if options.trap
          options.cmd
          'EOF'
        ].join '\n'
      , callback
