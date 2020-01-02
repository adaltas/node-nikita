
# `nikita.file.glob`

Search for files in a directory hierarchy.

## Implementation

The action use the POXIX `find` command to fetch all files and filter the
paths locally using the Minimatch package.

## Options

* `dot` (string)   
  Minimatch option to handle files starting with a ".".
* `target` (string)   
  The file or directory to compute the hash from.
* `minimatch` (object)   
  Pass any options to Minimatch.

## Callback information

* `hash`   
  The hash of the file or directory identified by the "target" option.

    module.exports = shy: true, handler: ({metadata, options}, callback) ->
      @log message: "Entering file.glob", level: 'DEBUG', module: 'nikita/lib/file/hash'
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: target, got #{JSON.stringify options.target}" unless options.target
      options.minimatch ?= {}
      options.minimatch.dot ?= options.dot if options.dot?
      info = {}
      options.target = path.normalize options.target
      minimatch = new Minimatch options.target, options.minimatch
      @system.execute
        cmd: [
          'find'
          ...(getprefix s for s in minimatch.set)
        ].join ' '
        trim: true
        relax: true
      , (err, {stdout}) ->
        # `find` return exit code 1 when no match is found,
        # we treat this scenario as an empty output
        files = string.lines(stdout).filter (file) ->
          minimatch.match file
        for s in minimatch.set
          n = 0
          while typeof s[n] is "string" then n++
          if s[n] is Minimatch.GLOBSTAR
            prefix = getprefix s
            files.unshift prefix if prefix
        info.status = true
        info.files = files
      @next (err) ->
        callback err, info

## Dependencies

    path = require 'path'
    {Minimatch} = require 'minimatch'
    string = require '../misc/string'

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
