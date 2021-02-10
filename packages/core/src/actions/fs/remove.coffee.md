
# `nikita.fs.remove`

Recursively remove files, directories and links. This is a much more aggressive
version of `unlink` based on the `rm` command.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if files were removed.   

## Implementation details

Files are removed localling using the Unix "rm" utility.

## Simple example

```js
const {status} = await nikita.fs.remove('./some/dir')
console.info(`Directory was removed: ${status}`)
```

## Removing a directory unless a given file exists

```js
const {status} = await nikita.fs.remove({
  target: './some/dir',
  unless_exists: './some/file'
})
console.info(`Directory was removed: ${status}`)
```

## Removing multiple files and directories

```js
const {status} = await nikita.fs.remove([
  { target: './some/dir', unless_exists: './some/file' },
  './some/file'
])
console.info(`Directories was removed: ${status}`)
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
        'recursive':
          type: 'boolean'
          description: '''
          Attempt to remove the file hierarchy rooted in the directory.
          '''
        'source':
          type: 'string'
          description: """
          Alias for "target".
          """
        'target':
          type: 'string'
          description: """
          File, directory or glob (pattern matching based on wildcard
          characters).
          """

## Handler

    handler = ({config, tools: {log}}) ->
      # Start real work
      {files} = await @fs.glob config.target
      for file in files
        log message: "Removing file #{file}", level: 'INFO'
        try
          {status} = await @execute
            command: [
              'rm'
              '-d' # Attempt to remove directories as well as other types of files.
              '-r' if config.recursive
              file
              # "rm -rf '#{file}'"
            ].join ' '
          log message: "File #{file} removed", level: 'WARN' if status
        catch err
          err.message = [
            'failed to remove the file, got message'
            JSON.stringify err.stderr.trim()
          ].join ' ' if utils.string.lines(err.stderr.trim()).length is 1
          throw err
      {}

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema

## Dependencies

    utils = require '../../utils'
