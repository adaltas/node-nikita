
# `mecano.assert(options, [callback])`

A set of assertion tools.

## Options

*   `status` (boolean)   
    Ensure the current status match the provided value.   

## Callback Parameters

*   `err`   
    Error object if assertion failed.   

## Source Code

    module.exports = (options) ->
      options.log message: "Entering assert", level: 'DEBUG', module: 'mecano/lib/assert'

## Check current status

```js
mecano.assert({
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

## Check server listening

```js
mecano.assert({
  ssh: connection   
  host: 'localhost'
  port: 80
}, function(err){
  console.log(err);
});
```

      throw Error "Required option port if host" if options.host and not options.port
      throw Error "Required option host if port" if options.port and not options.host
      @execute
        if: options.host
        cmd: "bash -c 'echo > /dev/tcp/#{options.host}/#{options.port}'"
      , (err) ->
        throw Error "Closed Connection to '#{options.host}:#{options.port}'" if err
