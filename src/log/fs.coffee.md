
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
    the mustache templating engine. Default to "{{hostname}}.log", where 
    "hostname" is the ssh host or localhost.   
*   `serializer` (object)   
    TODO...

## Layout

By default, a file name "{hostname}.log" will be created inside the base
directory defined by the option "basedir". Note, the base directory is a
required option. The path looks like "{options.basedir}/{hostname}.log".

If the option "archive" is activated, a folder named after the current time is
created inside the base directory. A symbolic link named as "latest" will point
this is direction. The paths look like "{options.basedir}/{time}/{hostname}.log"
and "{options.basedir}/latest".

## Source Code

    module.exports = ssh: null, handler: (options) ->
      # Validate options
      throw Error 'Missing option: "basedir"' unless options.basedir
      throw Error "Missing option: serializer" unless options.serializer
      # Normalize
      options.archive ?= false
      options.basedir ?= 'log'
      options.basedir = path.resolve options.basedir
      options.filename ?= "{{hostname}}.log"
      # Render
      options.hostname ?= options.ssh?.config.host or 'localhost'
      options.basedir = mustache.render options.basedir, options
      options.filename = mustache.render options.filename, options
      # Archive options
      unless options.archive
        logdir = path.resolve options.basedir
      else
        latestdir = path.resolve options.basedir, 'latest'
        now = new Date()
        options.archive = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2) if options.archive is true
        # dateformat = "#{now.getFullYear()}-#{('0'+now.getMonth()).slice -2}-#{('0'+now.getDate()).slice -2}"
        # dateformat += " #{('0'+now.getHours()).slice -2}-#{('0'+now.getMinutes()).slice -2}-#{('0'+now.getSeconds()).slice -2}"
        logdir = path.resolve options.basedir, options.archive      
      @mkdir shy: true, logdir
      # Events
      @call ->
        options.stream ?= fs.createWriteStream path.resolve logdir, options.filename
        @call options, stream
      @link
        if: latestdir
        shy: true
        source: logdir
        target: latestdir

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
    stream = require './stream'
