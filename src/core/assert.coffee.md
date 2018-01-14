
# `nikita.assert(options, [callback])`

A set of assertion tools.

## Options

* `status` (boolean)   
  Ensure the current status match the provided value.   

## Callback Parameters

* `err`   
  Error object if assertion failed.   

## Source Code

    module.exports = (options) ->
      options.log message: "Entering assert", level: 'DEBUG', module: 'nikita/lib/assert'

## Check current status

```js
nikita.assert({
  ssh: connection   
  status: true
}, function(err){
  console.log(err ? err.message : 'Assertion is ok');
});
```

      status = @status()
      @call
        if: options.status? and status isnt options.status
        handler: ->
          message = "Invalid status: expected #{JSON.stringify options.status}, got #{JSON.stringify status}"
          throw Error message
