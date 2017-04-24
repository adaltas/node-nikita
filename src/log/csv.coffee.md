
# `nikita.log.csv(options, [callback])`

Write log to the host filesystem in CSV.

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
  the mustache templating engine. Default to "{{shortname}}.log", where 
  "shortname" is the ssh host or localhost.   

## Source Code

    module.exports = ssh: null, handler: (options) ->
      stdouting = 0
      @call options, log_fs, serializer:
        'diff': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message},\n"
        'end': ->
          "lifecycle,INFO,Finished with success,\n"
        'error': (err) ->
          content = []
          content.push "lifecycle,ERROR,Finished with error,\n"
          print = (err) ->
            content.push "lifecycle,ERROR,#{err.stack or err.message},\n"
          unless err.errors
          then print err
          else if err.errors then for error in err.errors then print error
          content.join()
        'header': (log) ->
          "#{log.type},,,#{log.header}\n"
        'stdin': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message},\n"
        'stderr': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message},\n"
        'stdout': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message},\n"
        'text': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message},\n"

## Dependencies

    log_fs = require './fs'
