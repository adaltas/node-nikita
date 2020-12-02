
# `nikita.file.touch`

Create a empty file if it does not yet exists.

## Implementation details

Status will only be true if the file was created.

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file was created or modified.   

## Example

```js
const {status} = await nikita.file.touch({
  ssh: ssh,
  target: '/tmp/a_file'
})
console.info(`File was touched: ${status}`)
```

## Hooks

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'gid':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/gid'
        'mode':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chmod#/properties/mode'
        'target':
          oneOf: [{type: 'string'}, {typeof: 'function'}]
          description: """
          File path where to write file or a function that returns a valid file
          path.
          """
        'uid':
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/uid'
      required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      log message: "Entering file.touch", level: 'DEBUG', module: 'nikita/lib/file/touch'
      # status is false if the file doesn't exist and true otherwise
      {status} = await @call ->
        log message: "Check if target exists \"#{config.target}\"", level: 'DEBUG', module: 'nikita/lib/file/touch'
        {exists} = await @fs.base.exists target: config.target
        log message: "Destination does not exists", level: 'INFO', module: 'nikita/lib/file/touch' if not exists
        !exists
      # if the file doesn't exist, create a new one
      if status
        @file
          content: ''
          target: config.target
          mode: config.mode
          uid: config.uid
          gid: config.gid
      # if the file exists, overwrite it using `touch` but don't update the status
      else
        # todo check uid/gid/mode
        @execute
          command: "touch #{config.target}"
          shy: true
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema
