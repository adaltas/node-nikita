
# `nikita.wait`

Simple nikita action that calls setTimeout. Thus, time is in millisecond.

## Options

* `time` (number)    
  Time in millisecond to wait to.   

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

## Source Code

    module.exports = ({options}, callback) ->
      options.time ?= options.argument
      return callback Error "Missing time: #{JSON.stringify options.time}" unless options.time?
      options.time = parseInt options.time if typeof options.time is 'string'
      return callback Error "Invalid time format: #{JSON.stringify options.time}" unless typeof options.time is 'number'
      setTimeout callback, options.time
