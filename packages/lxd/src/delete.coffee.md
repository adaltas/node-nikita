
# `nikita.lxd.delete`

Delete a Linux Container using lxd.

## Example

```
require('nikita')
.lxd.delete({
  container: "myubuntu"
}, function(err, {status}) {
  console.info( err ? err.message : 'The container was deleted')
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
        'force':
          type: 'boolean'
          default: false
          description: """
          If true, the container will be deleted even if running.
          """
      required: ['container']

## Handler

    handler = ({config}) ->
      # log message: "Entering lxd.delete", level: 'DEBUG', module: '@nikitajs/lxd/lib/delete'
      @execute
        cmd: """
        lxc info #{config.container} > /dev/null || exit 42
        #{[
          'lxc',
          'delete',
          config.container
          "--force" if config.force
        ].join ' '}
        """
        code_skipped: 42

## Export

    module.exports =
      handler: handler
      schema: schema
