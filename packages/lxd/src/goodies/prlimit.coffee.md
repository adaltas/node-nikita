
# `nikita.lxd.goodies.prlimit`

Print the process limit associated with a running container.

## Options

* `container` (string, required)
  The name of the container.

## Output

* `error` (object)
  The error object, if any.
* `output.stdout` (string)
  The standard output from the `prlimit` command.
* `output.limits` (array)
  The limit object parsed from `stdout`; each element of the array contains the
  keys `resource`, `description`, `soft`, `hard` and `units`.

## Exemple

```js
require('nikita')
.lxd.goodies.prlimit({
  container: "my_container"
}, function(err, {stdout, limits}) {
  console.info( err ? err.message : stdout + JSON.decode(limits))
});
```

    module.exports = shy: true, handler: ({options}, callback) ->
      @log message: "Entering lxd.goodies.prlimit", level: 'DEBUG', module: '@nikitajs/lxd/lib/goodies/prlimit'
      # Validation
      throw Error "Invalid Option: container is required" unless options.container
      validate_container_name options.container
      @system.execute
        cmd: """
        command -p prlimit || exit 3
        prlimit -p $(lxc info #{options.container} | awk '$1==\"Pid:\"{print $2}')
        """
      , (error, {code, stdout}) ->
        return callback Error 'Invalid Requirement: this action requires prlimit installed on the host' if error and code is 3
        return callback error if error
        limits = for line, i in string.lines stdout
          continue if i is 0
          [resource, description, soft, hard, units] = line.split /\s+/
          resource: resource
          description: description
          soft: soft
          hard: hard
          units: units
        callback null, stdout: stdout, limits: limits

## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
    validate_container_name = require '../misc/validate_container_name'
