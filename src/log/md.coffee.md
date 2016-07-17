
# Log Markdown

Write log to the host filesystem.

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

    module.exports = ssh: null, handler: (options) ->
      # Normalize
      options.archive ?= false
      options.basedir ?= 'log'
      options.basedir = path.resolve options.basedir
      options.filename ?= "{{shortname}}.log"
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
          out.write "#{log.message}"
          out.write " (#{log.level}, written by #{log.module})" if log.module
          out.write "\n"
        @on 'header', (log) ->
          out.write "\n#{'#'.repeat log.header_depth} #{log.message}\n\n"
        @on 'stdin', (log) ->
          if log.message.indexOf('\n') is -1
          then out.write "\nRunning Command: `#{log.message}`\n\n"
          else out.write "\n```stdin\n#{log.message}\n```\n\n"
          stdining = log.message isnt null
        @on 'diff', (log) ->
          out.write '\n```diff\n#{log.message}```\n\n' unless log.message
        @on 'stdout_stream', (log) ->
          # return if log.message is null and stdouting is 0
          if log.message is null
          then stdouting = 0
          else stdouting++
          out.write '\n```stdout\n' if stdouting is 1
          out.write log.message if stdouting > 0
          out.write '```\n\n' if stdouting is 0
        @on 'stderr', (log) ->
          out.write "\n```stderr\n#{log.message}```\n\n"
        close = ->
          setTimeout (-> out.close()), 100
        @on 'end', ->
          out.write '\nFINISHED WITH SUCCESS\n'
          close()
        @on 'error', (err) ->
          out.write '\nFINISHED WITH ERROR\n'
          print = (err) ->
            out.write err.stack or err.message + '\n'
          unless err.errors
            print err
          else if err.errors
            out.write err.message + '\n'
            for error in err.errors then print error
          close()

## Dependencies

    fs = require 'fs'
    path = require 'path'
    mustache = require 'mustache'
