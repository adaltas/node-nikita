# `docker_cp(options, next)`

Copy files/folders between a container and the local filesystem.

Reflecting the original docker ps command usage, source and destination may take
the following forms:

*   CONTAINER:PATH 
*   LOCALPATH
*   process.readableStream as the source or process.writableStream as the
    destination (equivalent of "-")

Note, stream are not yet supported.

## Options

*   `machine` (string)
    Name of the docker-machine, MANDATORY if using docker-machine or boot2docker.
*   `source` (string)
    The path to upload or the container followed by the path to download.   
*   `destination` (string)
    The path to download or the container followed by the path to upload.   

## Uploading a file

```javascript
mecano.docker({
  source: readable_stream or '/path/to/source'
  destination: 'my_container:/path/to/destination'
}, function(err, status){})
```

## Downloading a file

```javascript
mecano.docker({
  source: 'my_container:/path/to/source'
  destination: writable_stream or '/path/to/destination'
}, function(err, status){})
```

## Source Code

    module.exports = (options) ->
      # Validate parameters
      options.docker ?= {}
      options[k] ?= v for k, v of options.docker
      throw Error 'Missing option "source"' unless options.source
      throw Error 'Missing option "destination"' unless options.destination
      [_, source_container, source_path] = /(.*:)?(.*)/.exec options.source
      [_, destination_container, destination_path] = /(.*:)?(.*)/.exec options.destination
      throw Error 'Incompatible source and destination options' if source_container and destination_container
      throw Error 'Incompatible source and destination options' if not source_container and not destination_container
      source_mkdir = false
      destination_mkdir = false
      @call (_, next) ->
        return next() if source_container
        if /\/$/.test source_path
          source_path = "#{source_path}/#{path.basename destination_path}"
          return next()
        ssh2fs.stat options.ssh, source_path, (err, stat) ->
          return next err if err and err.code isnt 'ENOENT'
          return destination_mkdir = true and next() if err?.code is 'ENOENT'
          source_path = "#{source_path}/#{path.basename destination_path}" if stat.isDirectory()
          next()
      @mkdir
        destination: source_path
        if: -> source_mkdir
      @call (_, next)  ->
        return next() if destination_container
        if /\/$/.test destination_path
          destination_path = "#{destination_path}/#{path.basename destination_path}"
          return next()
        ssh2fs.stat options.ssh, destination_path, (err, stat) ->
          return next err if err and err.code isnt 'ENOENT'
          return destination_mkdir = true and next() if err?.code is 'ENOENT'
          destination_path = "#{destination_path}/#{path.basename destination_path}" if stat.isDirectory()
          next()
      @mkdir
        destination: destination_path
        if: -> destination_mkdir
      @execute
        cmd: docker.wrap options, "cp #{options.source} #{options.destination}"
      , docker.callback

## Modules Dependencies

    # file = require('../misc').file
    path = require 'path'
    ssh2fs = require 'ssh2-fs'
    docker = require '../misc/docker'
