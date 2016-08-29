
# `mecano.docker.cp(options, [callback])`

Copy files/folders between a container and the local filesystem.

Reflecting the original docker ps command usage, source and target may take
the following forms:

*   CONTAINER:PATH 
*   LOCALPATH
*   process.readableStream as the source or process.writableStream as the
    target (equivalent of "-")

Note, stream are not yet supported.

## Options

*   `boot2docker` (boolean)   
    Whether to use boot2docker or not, default to false.   
*   `machine` (string)   
    Name of the docker-machine, required if using docker-machine or boot2docker.   
*   `source` (string)   
    The path to upload or the container followed by the path to download.   
*   `target` (string)   
    The path to download or the container followed by the path to upload.   

## Uploading a file

```javascript
mecano.docker({
  source: readable_stream or '/path/to/source'
  target: 'my_container:/path/to/target'
}, function(err, status){})
```

## Downloading a file

```javascript
mecano.docker({
  source: 'my_container:/path/to/source'
  target: writable_stream or '/path/to/target'
}, function(err, status){})
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering Docker cp", level: 'DEBUG', module: 'mecano/lib/docker/cp'
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing option "source"' unless options.source
      throw Error 'Missing option "target"' unless options.target
      [_, source_container, source_path] = /(.*:)?(.*)/.exec options.source
      [_, target_container, target_path] = /(.*:)?(.*)/.exec options.target
      throw Error 'Incompatible source and target options' if source_container and target_container
      throw Error 'Incompatible source and target options' if not source_container and not target_container
      source_mkdir = false
      target_mkdir = false
      # Source is on the host, normalize path
      @call (_, next) ->
        return next() if source_container
        if /\/$/.test source_path
          source_path = "#{source_path}/#{path.basename target_path}"
          return next()
        ssh2fs.stat options.ssh, source_path, (err, stat) ->
          return next err if err and err.code isnt 'ENOENT'
          # TODO wdavidw: seems like a mistake to me, we shall have source_mkdir instead
          return target_mkdir = true and next() if err?.code is 'ENOENT'
          source_path = "#{source_path}/#{path.basename target_path}" if stat.isDirectory()
          next()
      @mkdir
        target: source_path
        if: -> source_mkdir
      # Destination is on the host
      @call (_, next)  ->
        return next() if target_container
        if /\/$/.test target_path
          target_path = "#{target_path}/#{path.basename target_path}"
          return next()
        ssh2fs.stat options.ssh, target_path, (err, stat) ->
          return next err if err and err.code isnt 'ENOENT'
          return target_mkdir = true and next() if err?.code is 'ENOENT'
          target_path = "#{target_path}/#{path.basename target_path}" if stat.isDirectory()
          next()
      @mkdir
        target: target_path
        if: -> target_mkdir
      @execute
        cmd: docker.wrap options, "cp #{options.source} #{options.target}"
      , docker.callback

## Modules Dependencies

    # file = require('../misc').file
    path = require 'path'
    ssh2fs = require 'ssh2-fs'
    docker = require '../misc/docker'
