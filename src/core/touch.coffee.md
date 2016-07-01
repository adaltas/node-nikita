
# `touch(options, callback)`

Create a empty file if it does not yet exists.

## Implementation details

Internally, it delegates most of the work to the `mecano.write` module. It isn't
yet a real `touch` implementation since it doesnt change the file time if it
exists.

## Options

*   `target`   
    File path where to write content to.   
*   `gid`   
    File group name or group id.   
*   `uid`   
    File user name or user id.   
*   `mode`   
    File mode (permission and sticky bits), default to `0666`, in the form of
    `{mode: 0o0744}` or `{mode: "0744"}`.   


## Example

```js
require('mecano').touch({
  ssh: ssh,
  target: '/tmp/a_file'
}, function(err, touched){
  console.log(err ? err.message : 'File touched: ' + !!touched);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering touch", level: 'DEBUG', module: 'mecano/lib/touch'
      # Validate parameters
      options.target = options.argument if options.argument?
      return callback new Error "Missing target: #{options.target}" unless options.target
      options.log message: "Check if target exists \"#{options.target}\"", level: 'DEBUG', module: 'mecano/lib/touch'
      fs.exists options.ssh, options.target, (err, exists) =>
        return callback err if err
        return callback() if exists
        options.log message: "Destination does not exists", level: 'INFO', module: 'mecano/lib/touch'
        @write
          content: ''
          target: options.target
        @then callback

## Dependencies

    fs = require 'ssh2-fs'
