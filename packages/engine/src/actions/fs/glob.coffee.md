
# `nikita.fs.glob`

Search for files in a directory hierarchy.

## Implementation

The action use the POXIX `find` command to fetch all files and filter the
paths locally using the Minimatch package.

## Callback information

* `hash`   
  The hash of the file or directory identified by the "target" option.

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?

## Schema

    schema =
      type: 'object'
      properties:
        'dot':
          type: 'boolean'
          description: """
          Minimatch option to handle files starting with a ".".
          """
        'target':
          type: 'string'
          description: """
          The file or directory to compute the hash from.
          """
        'trailing':
          type: 'boolean'
          default: false
          description: """
          Leave a slash at the end of directories.
          """
        'minimatch':
          type: 'object'
          description: """
          Pass any additionnal config to Minimatch.
          """
      required: ['target']

## Handler

    handler = ({config, metadata, tools: {path}}) ->
      config.minimatch ?= {}
      config.minimatch.dot ?= config.dot if config.dot?
      config.target = path.normalize config.target
      minimatch = new Minimatch config.target, config.minimatch
      {stdout, exit_code} = await @execute
        cmd: [
          'find'
          ...(getprefix s for s in minimatch.set)
          # trailing slash
          '-type d -exec sh -c \'printf "%s/\\n" "$0"\' {} \\; -or -print'
        ].join ' '
        relax: true
        trim: true
      # Find returns exit code 1 when no match is found, treat it as an empty output
      stdout ?= ''
      # Filter each entries
      files = utils.string.lines(stdout).filter (file) ->
        minimatch.match file
      # Remove the trailing slash introduced by the find command
      unless config.trailing
        files = files.map (file) ->
          if file.slice(-1) is '/'
          then file.slice 0, -1
          else file
      files: files

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        shy: true
      schema: schema

## Dependencies

    {Minimatch} = require 'minimatch'
    utils = require '../../utils'

## Utility

    getprefix = (pattern) ->
      prefix = null
      n = 0
      while typeof pattern[n] is "string" then n++
      # now n is the index of the first one that is *not* a string.
      # see if there's anything else
      switch n
        # if not, then this is rather simple
        when pattern.length
          prefix = pattern.join '/'
          return prefix
        when 0
          # pattern *starts* with some non-trivial item.
          # going to readdir(cwd), but not include the prefix in matches.
          return null
        else
          # pattern has some string bits in the front.
          # whatever it starts with, whether that's "absolute" like /foo/bar,
          # or "relative" like "../baz"
          prefix = pattern.slice 0, n
          prefix = prefix.join '/'
          return prefix
