
# `nikita.lxc.wait.ready`

Wait for a container to be ready to use.

## Example

```js
const {$status} = await nikita.lxc.wait.ready({
  container: "myubuntu"
})
console.info(`Container is ready: ${$status}`)
```

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'container':
            $ref: 'module://@nikitajs/lxd/src/init#/definitions/config/properties/container'
          'nat':
            type: 'boolean'
            default: false
            description: """
            If true, will wait for internet to be connected
            """
          'nat_check':
            type: 'string'
            default: 'ping -c 3 8.8.8.8 || exit 42'
            description: '''
            Command use to check network activation. Expect exit code `0` when
            ready, exit code `42` if not yet ready and any other code on error.
            '''
        required: ['container']

## Handler

    handler = ({config}) ->
      {$status} = await @call
        $retry: 100
        $sleep: 1000
        () ->
          {config:{processes}} = await @lxc.state
            $header: "Checking if instance is ready"
            container: config.container
          # Processes are at -1 when they aren't ready
          if processes < 0
            throw Error "Reschedule: Instance not booted"
          # Sometimes processes alone aren't enough, so we test if we can get the container
          {$status} = await @lxc.exec
            $header: "Trying to execute a command"
            container: config.container
            command:"""
            if ( command -v systemctl || command -v rc-service ); then
              exit 0
            else 
              exit 42
            fi
            """
            code: [0, 42]
          if $status is false
            throw Error "Reschedule: Instance not ready to execute commands"
          # Checking if internet is working and ready for us to use
          if config.nat is true
            {$status} = await @lxc.exec
              $header: "Trying to connect to internet"
              container: config.container
              command: config.nat_check
              code: [0, 42]
            if $status is false
              throw Error "Reschedule: Internet not ready"
      $status: $status

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'container'
        definitions: definitions
