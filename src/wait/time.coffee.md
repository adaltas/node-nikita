
# `wait(options, callback)`

Simple mecano action that calls setTimeout. Thus, time is in millisecond.

## Options

*   `time` (number)    
    Time in millisecond to wait to.   

## Example

```coffee
before = Date.now()
require 'mecano'
.wait
  time: 5000
.then (err, status) ->
    throw Error 'TOO LATE!' if (Date.now() - before) > 5200
    throw Error 'TOO SOON!' if (Date.now() - before) < 5000
```

    module.exports = (options, callback) ->
      options = { time: options } if typeof options is 'number'
      return callback new Error "Missing time: #{options.time}" unless options.time?
      return callback new Error "Invalid time format '#{typeof options.time}'" unless typeof options.time is 'number'
      setTimeout callback, options.time
