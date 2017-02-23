
# `mecano.docker.save(options, [callback])`

Save Docker images

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `image` (string)   
    Name/ID of base image. __Mandatory__   
*   `tag` (string)   
    Tag of the image   
*   `machine` (string)   
    Name of the docker-machine. __Mandatory__ if using docker-machine   
*   `output` (string). __Mandatory__   
    TAR archive output path   
*   `target` (string). __Mandatory__   
    Shortcut for "output" option.   
*   `code` (int | array)   
    Expected code(s) returned by the command, int or array of int, default to 0.   
*   `code_skipped`   
    Expected code(s) returned by the command if it has no effect, executed will   
    not be incremented, int or array of int.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    if command was executed   
*   `stdout`   
    Stdout value(s) unless `stdout` option is provided.   
*   `stderr`   
    Stderr value(s) unless `stderr` option is provided.   

## Example

```javascript
mecano.docker({
  ssh: ssh
  output: 'test-image.tar'
  image: 'test-image'
  compression: 'gzip'
  entrypoint: '/bin/true'
}, function(err, is_true, stdout, stderr){
  if(err){
    console.log(err.message);
  }else if(is_true){
    console.log('OK!');
  }else{
    console.log('Ooops!');
  }
})
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker save", level: 'DEBUG', module: 'mecano/lib/docker/save'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      return callback Error 'Missing image parameter' unless options.image?
      options.output ?= options.target
      return callback Error 'Missing output parameter' unless options.output?
      # Saves image to local tmp path, than copy it
      cmd = "save -o #{options.output} #{options.image}"
      cmd += ":#{options.tag}" if options.tag?
      options.log message: "Extracting image #{options.output} to file:#{options.image}", level: 'INFO', module: 'mecano/lib/docker/save'
      @system.execute
        cmd: docker.wrap options, cmd
      , docker.callback

## Modules Dependencies

    util = require 'util'  
    docker = require '../misc/docker'
