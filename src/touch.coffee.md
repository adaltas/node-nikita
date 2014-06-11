
`touch([goptions], options, callback)`
--------------------------------------

Create a empty file if it does not yet exists.

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    write = require './write'

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