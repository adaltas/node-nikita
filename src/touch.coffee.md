
# `touch([goptions], options, callback)`

Create a empty file if it does not yet exists.

Internally, it delegates most of the work to the `mecano.write` module. It isnt
yet a real `touch` implementation since it doesnt change the file time if it
exists.

## Options

*   `destination`   
    File path where to write content to.   

## Example

```js
require('mecano').touch({
  ssh: ssh,
  destination: '/tmp/a_file'
}, function(err, touched){
  console.log(err ? err.message : "File touched: " + !!touched);
});
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, modified) ->
        callback err, modified if callback
        result.end err, modified
      misc.options options, (err, options) ->
        return finish err if err
        modified = 0
        each( options )
        .on 'item', (options, next) ->
          # Validate parameters
          {ssh, destination, mode} = options
          return next new Error "Missing destination: #{destination}" unless destination
          options.log? "Check if exists: #{destination}"
          fs.exists ssh, destination, (err, exists) ->
            return next err if err
            return next() if exists
            options.source = null
            options.content = ''
            options.log? "Create a new empty file"
            write options, (err, written) ->
              return next err if err
              modified++
              next()
        .on 'both', (err) ->
          finish err, modified

## Dependencies

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    write = require './write'






