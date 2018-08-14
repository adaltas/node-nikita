
# `nikita.ping`

Call ping, receive pong.

This constitutes a dummy action created for demonstration purposes.

## Options

* `content` (string)   
  Message to broadcast, default to "pong".   

## Callback Parameters

*   `err` (error)   
    Error object if assertion failed.   
*   `status` (boolean)   
    Always "true".   
*   `message` (string)   
    The content options.   

## Example


Status is always true and the default message is "pong".

```js
require('nikita')
.ping( {status, message} =>
  assert(status, true)
  assert(message, 'pong')
)
```

A custom message can be provided:

```js
require('nikita')
.ping({
  content: 'lorem ipsum'
}, {message} => 
  assert(message, 'lorem ipsum')
)
```

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering ping", level: 'DEBUG', module: 'nikita/lib/assert'
      options.content ?= 'pong'
      setImmediate =>
        @log message: "Sending #{options.content}", level: 'DEBUG', module: 'nikita/lib/assert'
        callback null, status: true, message: options.content
