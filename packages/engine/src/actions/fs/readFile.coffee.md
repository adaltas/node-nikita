
# `nikita.fs.readFile(options, callback)`

Options:

* `target` (string)   
  Path of the file to read; required.
* `encoding` (string)
  Return a string with a particular encoding, otherwise a buffer is returned; 
  optional.

Exemple:

```js
content = await require('nikita')
.fs.readFile({
  target: "#{scratch}/a_file",
  encoding: 'ascii'
})
```

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## schema

    schema =
      type: 'object'
      properties:
        'encoding':
          type: 'string'
          enum: require('../../utils/schema').encodings
          default: 'utf8'
          description: """
          The encoding used to decode the buffer into a string. The encoding can
          be any one of those accepted by Buffer. When not defined, this action
          return a Buffer instance.
          """
        'target':
          oneOf: [{type: 'string'}, 'instanceof': 'Buffer']
          description: """
          Source location of the file to read.
          """
      required: ['target']

## Handler

    handler = ({config, metadata, ssh}) ->
      @log message: "Entering fs.readFile", level: 'DEBUG', module: 'nikita/lib/fs/readFile'
      # Normalize options
      buffers = []
      await @fs.createReadStream
        target: config.target
        on_readable: (rs) ->
          while buffer = rs.read()
            buffers.push buffer
      data = Buffer.concat buffers
      data = data.toString config.encoding if config.encoding
      data

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        log: false
        raw_output: true
      schema: schema
