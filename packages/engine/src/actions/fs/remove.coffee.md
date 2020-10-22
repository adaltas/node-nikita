
# `nikita.fs.remove`

Recursively remove files, directories and links. This is a much more aggressive
version of `unlink` based on the `rm` command.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if files were removed.   

## Implementation details

Files are removed localling using the Unix "rm" utility. Porting [rimraf] over
SSH would be too slow.

## Simple example

```js
require('nikita')
.system.remove('./some/dir', function(err, {status}){
  console.log(err ? err.message : "File removed: " + status);
});
```

## Removing a directory unless a given file exists

```js
require('nikita')
.system.remove({
  target: './some/dir',
  unless_exists: './some/file'
}, function(err, {status}){
  console.log(err ? err.message : "File removed: " + status);
});
```

## Removing multiple files and directories

```js
require('nikita')
.system.remove([
  { target: './some/dir', unless_exists: './some/file' },
  './some/file'
], function(err, status){
  console.log(err ? err.message : 'File removed: ' + status);
});
```

## Hook

    on_action = ({config, metadata}) ->
      # Validate parameters
      config.target = metadata.argument if metadata.argument?
      config.target ?= config.source
      throw Error "Missing option: \"target\"" unless config.target?

## Schema

    schema =
      type: 'object'
      properties:
        'source':
          type: 'string'
          description: """
          Alias for "target".
          """
        'target':
          oneOf:[{type: 'string'}, {type: 'array'}]
          description: """
          File, directory or glob (pattern matching based on wildcard characters).   
          """

## Handler

    handler = ({config, metadata, tools: {log}}) ->
      # Start real work
      {files} = await @fs.glob config.target
      for file in files
        log message: "Removing file #{file}", level: 'INFO', module: 'nikita/lib/fs/remove'
        {status} = await @execute
          cmd: "rm -rf '#{file}'"
        log message: "File #{file} removed", level: 'WARN', module: 'nikita/lib/fs/remove' if status
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

[rimraf]: https://github.com/isaacs/rimraf
