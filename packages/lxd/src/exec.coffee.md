
# `nikita.lxd.file.push`

Push files into containers.

## Options

* `name` (string, required)   
  The name of the container.
* `cmd` (string, required)   
  The command to execute.

## Example

```
require('nikita')
.lxd.file.exec({
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
      @log message: "Entering lxd.file.exec", level: 'DEBUG', module: '@nikitajs/lxd/lib/exec'
      throw Error "Invalid Option: name is required, got #{JSON.stringify option.name}" unless option.name # note, name could be obtained from lxd_target
      @system.execute options,
        cmd: """
        cat <<EOF | lxc exec #{options.name} -- bash
        #{options.cmd}
        EOF
        """
      , callback
