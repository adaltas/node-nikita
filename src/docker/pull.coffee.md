
# `nikita.docker.pull`

Pull a container

## Options

* `tag` (string)   
  Name of the tag to pull.   
* `version` (string)   
  Version of the tag to control.  Default to `latest`.   
* `code_skipped` (string)   
  The exit code to skip if different from 0.   
* `all` (Boolean)   
  Download all tagged images in the repository.  Default to false.   

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  True if container was pulled.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Example

1- builds an image from dockerfile without any resourcess

```javascript
require('nikita')
.docker.pull({
  tag: 'postgresql'
}, function(err, {status}){
  console.log( err ? err.message : 'Container pulled: ' + status);
})
```

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering Docker pull", level: 'DEBUG', module: 'nikita/lib/docker/pull'
      # Global options
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      # Validate parameters
      version = options.version or options.tag.split(':')[1] or 'latest'
      delete options.version # present in misc.docker.options, will probably disappear at some point
      options.all ?= false
      cmd_images = 'images'
      cmd_images += " | grep '#{options.tag}'"
      cmd_images += " | grep '#{version}'" unless options.all
      throw Error 'Missing Tag Name' unless options.tag?
      # rm is false by default only if options.service is true
      cmd = 'pull'
      cmd += if options.all then  " -a #{options.tag}" else " #{options.tag}:#{version}"
      @system.execute
        cmd: docker.wrap options, cmd_images
        code_skipped: 1
      @system.execute
        unless: -> @status -1
        cmd: docker.wrap options, cmd
        code_skipped: options.code_skipped
      , callback

## Modules Dependencies


    docker = require '../misc/docker'
    util = require 'util'
