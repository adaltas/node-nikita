
# `touch([goptions], options, callback)`

Create a empty file if it does not yet exists.

## Implementation details

Internally, it delegates most of the work to the `mecano.write` module. It isn't
yet a real `touch` implementation since it doesnt change the file time if it
exists.

## Options

*   `destination`   
    File path where to write content to.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Example

```js
require('mecano').touch({
  ssh: ssh,
  destination: '/tmp/a_file'
}, function(err, touched){
  console.log(err ? err.message : "File touched: " + !!touched);
});
```

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, next) ->
        # Validate parameters
        {ssh, destination, mode} = options
        return next new Error "Missing destination: #{destination}" unless destination
        options.log? "Check if exists: #{destination}"
        fs.exists ssh, destination, (err, exists) ->
          return next err if err
          return next() if exists
          options.source = null
          options.content = ''
          options.log? "Create a new empty file"
          write options, (err, written) ->
            next err, written

## Dependencies

    fs = require 'ssh2-fs'
    wrap = require './misc/wrap'
    write = require './write'






