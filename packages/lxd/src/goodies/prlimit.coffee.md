
# `nikita.lxd.goodies.prlimit`

Print the process limit associated with a running container.

## Output

* `error` (object)
  The error object, if any.
* `output.stdout` (string)
  The standard output from the `prlimit` command.
* `output.limits` (array)
  The limit object parsed from `stdout`; each element of the array contains the
  keys `resource`, `description`, `soft`, `hard` and `units`.

## Example

```js
const {stdout, limits} = await nikita.lxd.goodies.prlimit({
  container: "my_container"
})
console.info( `${stdout} ${JSON.decode(limits)}`)
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
      required: ['container']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.goodies.prlimit", level: 'DEBUG', module: '@nikitajs/lxd/lib/goodies/prlimit'
      try
        {stdout} = await @execute
          command: """
          command -p prlimit || exit 3
          sudo prlimit -p $(lxc info #{config.container} | awk '$1==\"Pid:\"{print $2}')
          """
        limits = for line, i in utils.string.lines stdout
          continue if i is 0
          [resource, description, soft, hard, units] = line.split /\s+/
          resource: resource
          description: description
          soft: soft
          hard: hard
          units: units
        stdout: stdout, limits: limits
      catch err
        throw Error 'Invalid Requirement: this action requires prlimit installed on the host' if err.exit_code is 3

## Export

    module.exports =
      handler: handler
      schema: schema
      metadata:
        shy: true

## Dependencies

    utils = require '@nikitajs/engine/lib/utils'
