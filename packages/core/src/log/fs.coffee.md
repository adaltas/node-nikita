
# `nikita.log.fs`

Write log to the host filesystem in a user provided format.

## Options

* `archive` (boolean)   
  Save a copy of the previous logs inside a dedicated directory, default is
  "false".   
* `basedir` (string)    
  Directory where to store logs relative to the process working directory.
  Default to the "log" directory. Note, if the "archive" option is activated
  log file will be stored accessible from "./log/latest".   
* `filename` (string)   
  Name of the log file, contextually rendered with all options passed to
  the mustache templating engine. Default to "{{basename}}.log"   
* `basename` (string)   
  Default variable used by the filename rendering. Default to "localhost"   
* `serializer` (object)   
  An object of key value pairs where keys are the event types and the value is a
  function which must be implemented to serialize the information.

Global options can be alternatively set with the "log_fs" property.

## Layout

By default, a file name "{{basename}}.log" will be created inside the base
directory defined by the option "basedir". 
The path looks like "{options.basedir}/{hostname}.log".

If the option "archive" is activated, a folder named after the current time is
created inside the base directory. A symbolic link named as "latest" will point
this is direction. The paths look like "{options.basedir}/{time}/{hostname}.log"
and "{options.basedir}/latest".

## Source Code

    module.exports = ssh: false, handler: ({options}) ->
      # Obtains options from "log_fs" namespace
      options.log_fs ?= {}
      options[k] = v for k, v of options.log_fs
      # Validate options
      throw Error "Missing option: serializer" unless options.serializer
      # Normalize
      options.archive ?= false
      options.basedir ?= './log'
      options.basedir = path.resolve options.basedir
      options.basename ?= 'localhost'
      options.filename ?= "{{basename}}.log"
      # Render
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
      @system.mkdir shy: true, logdir
      # Events
      @call ->
        options.stream ?= fs.createWriteStream path.resolve logdir, options.filename
        @call options, stream
      @system.link
        if: latestdir
        shy: true
        source: logdir
        target: latestdir

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
    stream = require './stream'
