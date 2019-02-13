
# `nikita.file.properties`

Write a file in the Java properties format.

## Options

* `comment` (boolean)   
  Preserve comments, key is the comment while value is "null".
* `target` (string)   
  File to read and parse.
* `trim` (boolean)   
  Trim keys and value.
* `separator` (string)   
  The caracter to use for separating property and value. '=' by default.

## Exemple

Use a custom delimiter with spaces around the equal sign.

```javascript
require('nikita')
.file.properties.read({
  target: "/path/to/target.json",
  separator: ' = '
}, function(err, properties){
  console.info(err || properties);
})
```

## Source Code

    module.exports = status: false, handler: ({options}, callback) ->
      @log message: "Entering file.properties", level: 'DEBUG', module: 'nikita/lib/file/properties/read'
      # Options
      options.separator ?= '='
      options.comment ?= false
      options.encoding ?= 'utf8'
      throw Error "Missing argument options.target" unless options.target
      @fs.readFile target: options.target, encoding: options.encoding, (err, {data}) ->
        return callback err if err
        properties = {}
        # Parse
        lines = string.lines data
        for line in lines
          continue if /^\s*$/.test line # Empty line
          if /^#/.test line # Comment
            properties[line] = null if options.comment
            continue
          [_,k,v] = ///^(.*?)#{quote options.separator}(.*)$///.exec line
          k = k.trim() if options.trim
          v = v.trim() if options.trim
          properties[k] = v
        callback null, {properties: properties}

## Dependencies

    quote = require 'regexp-quote'
    string = require '../../misc/string'
