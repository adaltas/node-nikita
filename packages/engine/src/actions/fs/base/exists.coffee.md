
# `nikita.fs.exists`

Retrieve file information. If path is a symbolic link, then the link itself is
stat-ed, not the file that it refers to.

```js
require(nikita)
.fs.exists({
  target: '/path/to/file'
}, function(err, {exists}){
  console.info(err ? err.message :
    exists ? 'File exists' : 'File is missing')
})
```

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'target':
          type: 'string'
          description: """
          Destination file to check existance.
          """
      required: ['target']

## Handler

    handler = ({config}) ->
      @log message: "Entering fs.exists", level: 'DEBUG', module: 'nikita/lib/fs/exists'
      try
        await @fs.base.stat
          target: config.target
          dereference: true
        true
      catch err
        if err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          false
        else
          throw err

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema
