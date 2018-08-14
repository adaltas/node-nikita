
# `nikita.file.properties`

Write a file in the Java properties format.

## Options

* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `comment` (boolean)   
  Preserve comments.
* `content` (object)   
  List of properties to write.
* `local` (boolean)   
  Treat the source as local instead of remote, only apply with "ssh"
  option.
* `sort` (boolean)   
  Sort the properties before writting them. False by default.
* `target` (string)   
  File path where to write content to.
* `trim` (boolean)   
  Trim keys and value.
* `merge` (boolean)   
  Merges content properties with target file. False by default
* `separator` (string)   
  The caracter to use for separating property and value. '=' by default.

## Exemple

Use a custom delimiter with spaces around the equal sign.

```javascript
require('nikita')
.file.properties({
  target: "/path/to/target.json",
  content: { key: "value" },
  separator: ' = '
  merge: true
})
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering file.properties", level: 'DEBUG', module: 'nikita/lib/file/properties'
      # Options
      throw Error "Missing argument options.target" unless options.target
      options.separator ?= '='
      options.content ?= {}
      options.sort ?= false
      # Trim
      unless options.trim
        fnl_props = options.content
      else 
        fnl_props = {}
        for k, v of options.content
          k = k.trim()
          v = v.trim() if typeof v is 'string'
          fnl_props[k] = v
      org_props = {}
      @log message: "Merging \"#{if options.merge then 'true' else 'false'}\"", level: 'DEBUG', module: 'nikita/lib/file/properties'
      # Read Original
      @file.properties.read
        if_exists: true
        ssh: options.ssh
        target: options.target
        separator: options.separator
        comment: options.comment
        trim: options.trim
      , (err, {properties}) ->
        org_props = properties or {} unless err
      # Diff
      @call ({}, callback) ->
        status = false
        keys = {}
        for k in Object.keys(org_props) then keys[k] = true
        for k in Object.keys(fnl_props) then keys[k] = true
        for key in Object.keys keys
          if "#{org_props[key]}" isnt "#{fnl_props[key]}"
            @log message: "Property '#{key}' was '#{org_props[k]}' and is now '#{fnl_props[k]}'", level: 'WARN', module: 'ryba/lib/file/properties'
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
