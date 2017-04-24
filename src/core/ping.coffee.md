
# `nikita.ping(options, [callback])`

Call ping, receive pong.

## Options

* `content` (string)   
  Messasge to broadcast, default to "pong".   

## Callback Parameters

*   `err` (error)   
    Error object if assertion failed.   
*   `status` (boolean)   
    Always "true".
*   `message` (string)   
    The content options.

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering ping", level: 'DEBUG', module: 'nikita/lib/assert'
      options.content ?= 'pong'
      setImmediate ->
        options.log message: "Sending #{options.content}", level: 'DEBUG', module: 'nikita/lib/assert'
        callback null, true, options.content
