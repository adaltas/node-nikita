
# `nikita.lxd.file.exists`

Push files into containers.

## Example

```js
require('nikita')
.lxd.file.exists({
  container: "my_container"
}, function(err, {status}) {
  console.info( err ? err.message : 'The container was deleted')
});

```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          type: 'string'
          description: """
          The name of the container in which the file will be checked for
          existence.
          """
        'target':
          type: 'string'
          description: """
          File destination in the form of "<path>".
          """
      required: ['container', 'target']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.file.exists", level: 'DEBUG', module: '@nikitajs/lxd/lib/file/exists'
      # Validation
      validate_container_name config.container
      @execute
        cmd: """
        lxc exec #{config.container} -- stat #{config.target}
        """
        code_skipped: 1

## Export

    module.exports =
      handler: handler
      metadata:
        shy: true
      schema: schema

## Dependencies

    validate_container_name = require '../misc/validate_container_name'
