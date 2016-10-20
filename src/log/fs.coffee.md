
# `mecano.log.fs(options, [callback])`

Write log to the host filesystem in a user provided format.

## Options

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

## Source Code

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
      options.stream ?= fs.createWriteStream path.resolve options._logdir, options.filename
      # Layout
      @mkdir options.basedir
      @mkdir shy: true, options._logdir
      if options.archive
        @link
          shy: true
          source: options._logdir
          target: options._latestdir
      # Events
      @call options, stream

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
    stream = require './stream'
