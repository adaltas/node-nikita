
# `nikita.assert`

A set of assertion tools.

## Options

* `status` (boolean)   
  Ensure the current status match the provided value.   

## Callback Parameters

* `err`   
  Error object if assertion failed.   

## Source Code

    module.exports = ({metadata}) ->
      @log message: "Entering assert", level: 'DEBUG', module: 'nikita/lib/assert'

## Check current status

```js
nikita.assert({
  ssh: connection   
  status: true
}, function(err){
  console.log(err ? err.message : 'Assertion is ok');
});
```

      # Note, this isn't nice, we are hijacking the original status metadata
      # property and use it as an option
      status = @status()
      @call
        if: metadata.status? and status isnt metadata.status
      , ->
        message = "Invalid status: expected #{JSON.stringify metadata.status}, got #{JSON.stringify status}"
        throw Error message
