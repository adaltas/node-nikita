
# `nikita.docker.cp`

Copy files/folders between a container and the local filesystem.

Reflecting the original docker ps command usage, source and target may take
the following forms:

* CONTAINER:PATH 
* LOCALPATH
* process.readableStream as the source or process.writableStream as the
  target (equivalent of "-")

Note, stream are not yet supported.

## Uploading a file

```javascript
require('nikita')
.docker({
  source: readable_stream or '/path/to/source'
  target: 'my_container:/path/to/target'
}, function(err, {status}){
  console.log( err ? err.message : 'Container copied' + status)
)
```

## Downloading a file

```javascript
require('nikita')
.docker({
  source: 'my_container:/path/to/source',
  target: writable_stream or '/path/to/target'
}, function(err, status){
  console.log( err ? err.message : 'Container copied: ' + status);
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'source':
          type: 'string'
          description: """
          The path to upload or the container followed by the path to download.
          """
        'target':
          type: 'string'
          description: """
          The path to download or the container followed by the path to upload.
          """
        'boot2docker':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
        'compose':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
        'machine':
          $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
      required: ['source', 'target']

## Handler

    handler = ({config, log, tools: {find}}) ->
      log message: "Entering Docker cp", level: 'DEBUG', module: 'nikita/lib/docker/cp'
      # Global config
      config.docker = await find ({config: {docker}}) -> docker
      config[k] ?= v for k, v of config.docker
      [_, source_container, source_path] = /(.*:)?(.*)/.exec config.source
      [_, target_container, target_path] = /(.*:)?(.*)/.exec config.target
      throw Error 'Incompatible source and target config' if source_container and target_container
      throw Error 'Incompatible source and target config' if not source_container and not target_container
      source_mkdir = false
      target_mkdir = false
      # Source is on the host, normalize path
      unless source_container
        if /\/$/.test source_path
          source_path = "#{source_path}/#{path.basename target_path}"
        try
          {stats} = await @fs.base.stat ssh: config.ssh, target: source_path
          source_path = "#{source_path}/#{path.basename target_path}" if utils.stats.isDirectory stats.mode
        catch err
          throw err unless err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          # TODO wdavidw: seems like a mistake to me, we shall have source_mkdir instead
          target_mkdir = true
      @fs.mkdir
        target: source_path
        if: source_mkdir
      # Destination is on the host
      unless target_container
        if /\/$/.test target_path
          target_path = "#{target_path}/#{path.basename target_path}"
        try
          {stats} = await @fs.base.stat target: target_path
          target_path = "#{target_path}/#{path.basename target_path}" if utils.stats.isDirectory stats.mode
        catch err
          throw err unless err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          target_mkdir = true
      @fs.base.mkdir
        target: target_path
        if: target_mkdir
      @docker.tools.execute
        cmd: "cp #{config.source} #{config.target}"

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    path = require 'path'
    utils = require '@nikitajs/engine/lib/utils'
