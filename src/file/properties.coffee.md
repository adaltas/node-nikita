
# `nikita.file.properties(options, callback)`

Write a file in the Java properties format.

## Options

*   `backup` (boolean)
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.
*   `content`
    List of properties to write.
*   `target`
    File path where to write content to.
*   `local`
    Treat the source as local instead of remote, only apply with "ssh"
    option.
*   `sort`
    Sort the properties before writting them. False by default
*   `merge`
    Merges content properties with target file. False by default
*   `separator`
    The caracter to use for separating property and value. '=' by default.
*   `ssh` (object|ssh2)
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.
*   `stdout` (stream.Writable)
    Writable EventEmitter where diff information is written if option "diff" is
    "true".


## Source Code

    module.exports = (options) ->
      options.log message: "Entering file.properties", level: 'DEBUG', module: 'nikita/lib/file/properties'
      throw Error "Missing argument options.target" unless options.target
      options.separator ?= '='
      options.content ?= {}
      options.sort ?= false
      # org_props = if options.merge then {} else options.content
      fnl_props = options.content
      org_props = {}
      options.log message: "Merging \"#{if options.merge then 'true' else 'false'}\"", level: 'DEBUG', module: 'nikita/lib/file/properties'
      # Read Original
      @call (_, callback) ->
        options.log message: "Reading target \"#{options.target}\"", level: 'DEBUG', module: 'nikita/lib/file/properties'
        module.exports.properties options, (err, props) ->
          return callback err if err
          org_props = props
          callback()
      # Diff
      @call (_, callback) ->
        status = false
        keys = {}
        for k in Object.keys(org_props) then keys[k] = true
        for k in Object.keys(fnl_props) then keys[k] = true # unless keys[k]?
        for key in Object.keys keys
          if "#{org_props[key]}" isnt "#{fnl_props[key]}"
            options.log? message: "Property '#{key}' was '#{org_props[k]}' and is now '#{fnl_props[k]}'", level: 'WARN', module: 'ryba/lib/file/properties'
            status = true if fnl_props[key]?
        callback null, status
      # Merge
      @call if: options.merge, ->
        for k, v of fnl_props
          org_props[k] = fnl_props[k]
        fnl_props = org_props
      @call ->
        # Write data
        keys = if options.sort then Object.keys(fnl_props).sort() else Object.keys(fnl_props)
        data = for key in keys
          if fnl_props[key]?
          then "#{key}#{options.separator}#{fnl_props[key]}"
          else "#{key}" # This is a comment
        @file
          target: "#{options.target}"
          content: data.join '\n'
          backup: options.backup
          eof: true
          shy: true
        @system.chown
          target: options.target
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?
        @system.chmod
          target: options.target
          mode: options.mode
          if: options.mode?

    module.exports.properties = (options, callback) ->
      fs.readFile options.ssh, options.target, 'utf8', (err, data) ->
        return callback null, {} if err?.code is 'ENOENT'
        return callback err if err
        props = {}
        # Parse
        lines = string.lines data
        for line in lines
          continue if /^\s*$/.test line # Empty line
          if /^#/.test line # Comment
            props[line] = null if options.comment
            continue
          [_,k,v] = ///^(.*?)#{quote options.separator}(.*)$///.exec line
          props[k] = v
        callback null, props

## Dependencies

    fs = require 'ssh2-fs'
    quote = require 'regexp-quote'
    string = require '../misc/string'
