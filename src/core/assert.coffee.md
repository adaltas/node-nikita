
# `assert(options)`

A set of assertion tools.

## Option properties

*   `status` (boolean)   
    Ensure the current status match the provided value.   

## Example status

```js
mecano.assert({
  ssh: connection   
  status: true
}, function(err){
  console.log(err);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering assert", level: 'DEBUG', module: 'mecano/lib/assert'
      throw Error "Invalid status: expected #{JSON.stringify options.status}, got #{JSON.stringify @status()}" unless @status() is options.status
