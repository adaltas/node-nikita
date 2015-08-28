
# `touch(options, callback)`

Create a empty file if it does not yet exists.

## Implementation details

Internally, it delegates most of the work to the `mecano.write` module. It isn't
yet a real `touch` implementation since it doesnt change the file time if it
exists.

## Options

*   `destination`   
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
  destination: '/tmp/a_file'
}, function(err, touched){
  console.log(err ? err.message : 'File touched: ' + !!touched);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters
      {ssh, destination, mode} = options
      return callback new Error "Missing destination: #{destination}" unless destination
      options.log? "Check if exists: #{destination}"
      fs.exists ssh, destination, (err, exists) =>
        return callback err if err
        return callback() if exists
        options.source = null
        options.content = ''
        options.log? "Create a new empty file"
        options.handler = undefined
        @write options
        .then callback

## Dependencies

    fs = require 'ssh2-fs'






