
# `mecano.touch(options, [callback])`

Create a empty file if it does not yet exists.

## Implementation details

Internally, it delegates most of the work to the `mecano.write` module. It isn't
yet a real `touch` implementation since it doesnt change the file time if it
exists. This is expected to change soon.

## Options

*   `target`   
    File path where to write content to.   
*   `gid`   
    File group name or group id.   
*   `uid`   
    File user name or user id.   
*   `mode`   
    File mode (permission and sticky bits), default to `0o0666`, in the form of
    `{mode: 0o0744}` or `{mode: "0744"}`.   

## Callback Parameters

*   `err`   
    Error object if any.   
*   `status`   
    Value is "true" if file was created or modified.   

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

    module.exports = (options) ->
      options.log message: "Entering touch", level: 'DEBUG', module: 'mecano/lib/touch'
      # Options
      options.target = options.argument if options.argument?
      throw Error "Missing target: #{options.target}" unless options.target
      
Test if file exists.

      @call shy: true, (_, callback) ->
        options.log message: "Check if target exists \"#{options.target}\"", level: 'DEBUG', module: 'mecano/lib/touch'
        fs.exists options.ssh, options.target, (err, exists) ->
          options.log message: "Destination does not exists", level: 'INFO', module: 'mecano/lib/touch' if not err and not exists
          return callback err, exists

If not, write a new empty file.

      @file
        content: ''
        target: options.target
        unless: -> @status()
        mode: options.mode
        uid: options.uid
        gid: options.gid

## Dependencies

    fs = require 'ssh2-fs'
