
# `nikita.lxd.exec`

Execute command in containers.

## Example

```js
const {status, stdout, stderr} = await nikita.lxd.exec({
  container: "my-container",
  cmd: "whoami"
})
console.info(`Command was executed: ${status}`)
console.info(stdout)
```

## Todo

* Support `env` option

## Schema

    schema =
      type: 'object'
      properties:
        'container':
          $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
        'cmd':
          type: 'string'
          description: """
          The command to execute.
          """
        'trap':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/trap'
      required: ['container', 'cmd']

## Handler

    handler =  ({config}) ->
      # log message: "Entering lxd.exec", level: 'DEBUG', module: '@nikitajs/lxd/lib/exec'
      @execute config, trap: false,
        cmd: [
          "cat <<'NIKITALXDEXEC' | lxc exec #{config.container} -- bash"
          'set -e' if config.trap
          config.cmd
          'NIKITALXDEXEC'
        ].join '\n'

## Export

    module.exports =
      handler: handler
      schema: schema
