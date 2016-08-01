
# `mecano.log.fs(options, [callback])`

Write log to the host filesystem in a user provided format.

Options include:

*   `archive` (boolean)   
    Save a copy of the previous logs inside a dedicated directory, default is
    "false".   
*   `basedir` (string)    
    Directory where to store logs relative to the process working directory.
    Default to the "log" directory. Note, if the "archive" option is activated
    log file will be stored accessible from "./log/latest".   
*   `filename` (string)   
    Name of the log file, contextually rendered with all options passed to
    the mustache templating engine. Default to "{{shortname}}.log", where 
    "shortname" is the ssh host or localhost.   
*   `serializer` (object)   
    TODO...

    module.exports = ssh: null, handler: (options) ->
      # Normalize
      options.archive ?= false
      options.basedir ?= 'log'
      options.basedir = path.resolve options.basedir
      options.filename ?= "{{shortname}}.log"
      throw Error "Missing option: serializer" unless options.serializer
      # Render
      options.shortname ?= options.ssh?.config.host or 'localhost'
      options.basedir = mustache.render options.basedir, options
      options.filename = mustache.render options.filename, options
      # Archive options
      unless options.archive
        options._logdir ?= path.join options.basedir
      else
        options._latestdir ?= path.join options.basedir, 'latest'
        dateformat = (new Date).toJSON()
        # dateformat = "#{now.getFullYear()}-#{('0'+now.getMonth()).slice -2}-#{('0'+now.getDate()).slice -2}"
        # dateformat += " #{('0'+now.getHours()).slice -2}-#{('0'+now.getMinutes()).slice -2}-#{('0'+now.getSeconds()).slice -2}"
        options._logdir ?= path.join options.basedir, dateformat
      # Layout
      @mkdir options.basedir
      @mkdir shy: true, options._logdir
      if options.archive
        @link
          shy: true
          source: options._logdir
          target: options._latestdir
      # Events
      @call ->
        out = fs.createWriteStream path.resolve options._logdir, options.filename
        stdouting = 0
        @on 'text', (log) ->
          return unless options.serializer.text
          out.write options.serializer.text log
        @on 'header', (log) ->
          return unless options.serializer.header
          out.write options.serializer.header log
        @on 'stdin', (log) ->
          return unless options.serializer.stdin
          out.write options.serializer.stdin log
        @on 'diff', (log) ->
          return unless options.serializer.diff
          out.write options.serializer.diff log
        @on 'stdout_stream', (log) ->
          return unless options.serializer.stdout_stream
          # console.log log, options.serializer.stdout_stream log
          out.write options.serializer.stdout_stream log
        @on 'stderr', (log) ->
          return unless options.serializer.stderr
          out.write options.serializer.stderr log
        close = -> setTimeout (-> out.close()), 100
        @on 'end', ->
          out.write options.serializer.end log if options.serializer.end
          close()
        @on 'error', (err) ->
          out.write options.serializer.error log if options.serializer.error
          close()

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
