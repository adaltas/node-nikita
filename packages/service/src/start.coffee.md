
# `nikita.service.start`

Start a service.
Note, does not throw an error if service is not installed.

## Output

* `err`   
  Error object if any.   
* `status`   
  Indicates if the service was started ("true") or if it was already running 
  ("false").   

## Example

```js
const {status} = await nikita.service.start([{
  ssh: ssh,
  name: 'gmetad'
})
console.info(`Service was started: ${status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.name = metadata.argument if typeof metadata.argument is 'string'

## Schema

    schema =
      type: 'object'
      properties:
        'arch_chroot':
          $ref: 'module://@nikitajs/engine/lib/actions/execute#/properties/arch_chroot'
        'name':
          $ref: 'module://@nikitajs/service/src/install#/properties/name'
        'rootdir':
          $ref: 'module://@nikitajs/engine/lib/actions/execute#/properties/rootdir'
      required: ['name']

## Handler

    handler = ({config, tools: {log}}) ->
      try
        {status} = await @execute
          command: """
          ls \
            /lib/systemd/system/*.service \
            /etc/systemd/system/*.service \
            /etc/rc.d/* \
            /etc/init.d/* \
            2>/dev/null \
          | grep -w "#{config.name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status #{config.name} && exit 3
            systemctl start #{config.name}
          elif command -v service >/dev/null 2>&1; then
            service #{config.name} status && exit 3
            service #{config.name} start
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
          """
          code_skipped: 3
          arch_chroot: config.arch_chroot
          rootdir: config.rootdir
        log message: "Service is started", level: 'INFO', module: 'nikita/lib/service/start' if status
        log message: "Service already started", level: 'WARN', module: 'nikita/lib/service/start' if not status
      catch err
        throw Error "Unsupported Loader" if err.exit_code is 2

## Export

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
