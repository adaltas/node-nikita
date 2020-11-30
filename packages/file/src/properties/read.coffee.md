
# `nikita.file.properties.read`

Read a file in the Java properties format.

## Example

Use a custom delimiter with spaces around the equal sign.

```js
const {properties} = await nikita.file.properties.read({
  target: "/path/to/target.json",
  separator: ' = '
})
console.info(`Properties:`, properties)
```

## On config

    on_action = ({config}) ->
      # Options
      config.encoding ?= 'utf8'

## Schema

    schema =
      type: 'object'
      properties:
        'comment':
          type: 'boolean'
          default: false
          description: """
          Preserve comments, key is the comment while value is "null".
          """
        'separator':
          type: 'string'
          default: '='
          description: """
          The caracter to use for separating property and value. '=' by default.
          """
        'target':
          oneOf: [{type: 'string'}, {typeof: 'function'}]
          description: """
          File to read and parse.
          """
        'trim':
          type: 'boolean'
          description: """
          Trim keys and value.
          """
      required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      log message: "Entering file.properties", level: 'DEBUG', module: 'nikita/lib/file/properties/read'
      {data} = await @fs.base.readFile
        target: config.target
        encoding: config.encoding
      properties = {}
      # Parse
      lines = data.split /\r\n|[\n\r\u0085\u2028\u2029]/g
      for line in lines
        continue if /^\s*$/.test line # Empty line
        if /^#/.test line # Comment
          properties[line] = null if config.comment
          continue
        [_,k,v] = ///^(.*?)#{quote config.separator}(.*)$///.exec line
        k = k.trim() if config.trim
        v = v.trim() if config.trim
        properties[k] = v
      properties: properties

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

## Dependencies

    quote = require 'regexp-quote'
