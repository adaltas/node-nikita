
# `nikita.wait`

Wait for some time before executing the following action. Internally, this is a
simple action that calls setTimeout. Thus, time is in millisecond.

## Example

```js
before = Date.now();
require('nikita')
.wait({
  time: 5000
}, function(err, {status}){
  throw Error 'TOO LATE!' if (Date.now() - before) > 5200
  throw Error 'TOO SOON!' if (Date.now() - before) < 5000
})
```

## Hook

    on_action = ({config, metadata}) ->
      config.time ?= metadata.argument if metadata.argument?
      config.time = parseInt config.time if typeof config.time is 'string'

## Schema

    schema =
      type: 'object'
      properties:
        'time':
          type: 'integer'
          description: """
          Time in millisecond to wait for.
          """
      required: ['time']

## Handler

    handler = ({config, metadata}) ->
      new Promise (resolve) ->
        setTimeout resolve, config.time

## Exports

    module.exports =
      handler: handler
      on_action: on_action
      schema: schema
