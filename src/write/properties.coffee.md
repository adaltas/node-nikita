
# `write_properties(options, callback)`

Write a file in the Java properties format.

## Options

*   `backup` (boolean)
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.
*   `content`
    List of properties to write.
*   `target`
    File path where to write content to.
*   `local_source`
    Treat the source as local instead of remote, only apply with "ssh"
    option.
*   `merge`
    Merges content properties with target file. False by default
#   `separator`
    The caracter to use for separating property and value. '=' by default.
*   `ssh` (object|ssh2)
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.
*   `stdout` (stream.Writable)
    Writable EventEmitter where diff information is written if option "diff" is
    "true".


## Source Code

    module.exports = (options) ->
      options.log message: "Entering write_properties", level: 'DEBUG', module: 'mecano/lib/write_properties'
      throw Error "Missing argument options.target" unless options.target
      options.separator ?= '='
      options.content ?= {}
      properties = if options.merge then {} else options.content
      options.log message: "Merging \"#{if options.merge then 'true' else 'false'}\"", level: 'DEBUG', module: 'mecano/lib/write_properties'
      @call
        if: options.merge
        handler: (_, callback) ->
          options.log message: "Reading target \"#{options.target}\"", level: 'DEBUG', module: 'mecano/lib/write_properties'
          fs.readFile options.ssh, options.target, 'utf8', (err, data) ->
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
          target: "#{options.target}"
          content: data
          backup: options.backup
          eof: true

## Dependencies

    fs = require 'ssh2-fs'
    quote = require 'regexp-quote'
    string = require '../misc/string'
