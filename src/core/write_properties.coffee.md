
# `write_properties(options, callback)`

Write a file in the Java properties format.

## Source Code

    module.exports = (options) ->
      throw Error "Missing argument options.destination" unless options.destination
      options.separator ?= '='
      options.content ?= {}
      properties = if options.merge then {} else options.content
      options.log message: "Merging \"#{if options.merge then 'true' else 'false'}\"", level: 'DEBUG', module: 'mecano/lib/write_properties'
      @call
        if: options.merge
        handler: (_, callback) ->
          options.log message: "Reading destination \"#{options.destination}\"", level: 'DEBUG', module: 'mecano/lib/write_properties'
          fs.readFile options.ssh, options.destination, 'utf8', (err, data) ->
            return callback err if err
            # Extract properties
            lines = string.lines data
            for line in lines
              continue if /^#/.test line # Comment
              continue if /^\w*$/.test line # Empty line
              [_,k,v] = ///^(.*?)#{quote options.separator}(.*)$///.exec line
              properties[k] = v
            # Merge with user properties
            for k, v of options.content
              if v is null
                delete properties[k]
              else
                properties[k] = v
            callback()
      @call ->
        # Write data
        data = for k, v of properties
          "#{k}#{options.separator}#{v}"
        data = data.join '\n'
        @write
          destination: "#{options.destination}"
          content: data

## Dependencies

    fs = require 'ssh2-fs'
    quote = require 'regexp-quote'
    string = require '../misc/string'
