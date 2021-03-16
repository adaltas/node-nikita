
# `nikita.fs.base.exists`

Retrieve file information. If path is a symbolic link, then the link itself is
stat-ed, not the file that it refers to.

## Output

The returned object contains the properties:

* `exists` (boolean)
  Indicates if the target file exists.
* `target` (string)   
  Location of the target file.

## Example

```js
const {exists} = await nikita.fs.base.exists({
  target: '/path/to/file'
})
console.info(`File exists: ${exists}`)
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
          description: '''
          Destination file to check existance.
          '''
      required: ['target']

## Handler

    handler = ({config}) ->
      try
        await @fs.base.stat
          target: config.target
          dereference: true
        exists: true
        target: config.target
      catch err
        if err.code is 'NIKITA_FS_STAT_TARGET_ENOENT'
          exists: false
          target: config.target
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
