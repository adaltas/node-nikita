
# `file.json(options, callback)`

## Options

## Source Code

    module.exports = (options) ->
      options.content ?= {}
      options.prettify ?= false
      options.pretty = 2 if options.pretty is true
      options.transform ?= null
      throw Error "Invalid options: \"transform\"" if options.transform and typeof options.transform isnt 'function'
      @call if: options.merge, (_, callback) ->
        fs.readFile options.ssh, options.target, 'utf8', (err, json) ->
          options.content = merge JSON.parse(json), options.content unless err
          callback err
      @call if: options.source, (_, callback) ->
        ssh = if options.local then null else options.ssh
        fs.readFile ssh, options.source, 'utf8', (err, json) ->
          options.content = merge JSON.parse(json), options.content unless err
          callback err
      @call if: options.transform, ->
        options.content = options.transform options.content
      @file
        target: options.target
        content: -> JSON.stringify options.content, null, options.pretty
        backup: options.backup
        diff: options.diff
        eof: options.eof
        gid: options.gid
        uid: options.uid
        mode: options.mode
      
## Dependencies

    fs = require 'ssh2-fs'
    {merge} = require '../misc'
