
# `mecano.docker.pull(options, [callback])`

Pull a container

## Options
  
*   `tag` (string)   
    Name of the tag to pull.   
*   `version` (string)   
    Version of the tag to control.  Default to `latest`.   
*   `code_skipped` (string)   
    The exit code to skip if different from 0.   
*   `all` (Boolean)   
    Download all tagged images in the repository.  Default to false.   

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

1- builds an image from dockerfile without any resourcess

```javascript
mecano.docker_pull({
  tag: 'postgres'
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

    module.exports = (options, callback) ->
      options.log message: "Entering Docker pull", level: 'DEBUG', module: 'mecano/lib/docker/pull'
      # Validate parameters
      options.docker ?= {}
      options.version ?= 'latest'  
      options.all ?= false
      options[k] ?= v for k, v of options.docker
      cmd_images = 'images'
      cmd_images += " | grep '#{options.tag}'"
      cmd_images += " | grep '#{options.version}'" unless options.all            
      throw Error 'Missing Tag Name' unless options.tag?
      # rm is false by default only if options.service is true
      cmd = 'pull'
      cmd += if options.all then  " -a #{options.tag}" else " #{options.tag}:#{options.version}"
      @execute
        cmd: docker.wrap options, cmd_images
        code_skipped: 1
      @execute
        unless: -> @status -1
        cmd: docker.wrap options, cmd
        code_skipped: options.code_skipped
      , (err, status) -> callback err, status
      

## Modules Dependencies


    docker = require '../misc/docker'
    util = require 'util'
