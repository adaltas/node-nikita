
# `nikita.lxd.exec`

Execute command in containers.

## Example

```js
const {status, stdout, stderr} = await nikita.lxd.exec({
  container: "my-container",
  command: "whoami"
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
        'command':
          type: 'string'
          description: '''
          The command to execute.
          '''
        'shell':
          type: 'string'
          default: 'sh'
          description: '''
          The shell in which to execute commands, for example `sh`, `bash` or
          `zsh`.
          '''
        'trim':
          $ref: 'module://@nikitajs/core/lib/actions/execute#/properties/trim'
        'trap':
          $ref: 'module://@nikitajs/core/lib/actions/execute#/properties/trap'
      required: ['container', 'command']

## Handler

    handler =  ({config}) ->
      await @execute config, trap: false,
        command: [
          "cat <<'NIKITALXDEXEC' | lxc exec #{config.container} -- #{config.shell}"
          'set -e' if config.trap
          config.command
          'NIKITALXDEXEC'
        ].join '\n'

## Export

    module.exports =
      handler: handler
      metadata:
        schema: schema
