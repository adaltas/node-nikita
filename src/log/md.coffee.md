
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
      stdouting = 0
      @call options, log_fs, serializer:
        'diff': (log) ->
          "\n```diff\n#{log.message}```\n\n" unless log.message
        'end': ->
          '\nFINISHED WITH SUCCESS\n'
        'error': (err) ->
          content = []
          content.push '\nFINISHED WITH ERROR\n'
          print = (err) ->
            content.push err.stack or err.message + '\n'
          unless err.errors
            print err
          else if err.errors
            content.push err.message + '\n'
            for error in err.errors then content.push error
          content.join ''
        'header': (log) ->
          "\n#{'#'.repeat log.header_depth} #{log.message}\n\n"
        'stdin': (log) ->
          if log.message.indexOf('\n') is -1
          then out.write "\nRunning Command: `#{log.message}`\n\n"
          else out.write "\n```stdin\n#{log.message}\n```\n\n"
          stdining = log.message isnt null
        'stderr': (log) ->
          "\n```stderr\n#{log.message}```\n\n"
        'stdout_stream': (log) ->
          # return if log.message is null and stdouting is 0
          if log.message is null
          then stdouting = 0
          else stdouting++
          out = []
          out.push '\n```stdout\n' if stdouting is 1
          out.push log.message if stdouting > 0
          out.push '\n```\n\n' if stdouting is 0
          out.join ''
        'text': (log) ->
          content = []
          content.push "#{log.message}"
          content.push " (#{log.level}, written by #{log.module})" if log.module
          content.push "\n"
          content.join ''
        

## Dependencies

    log_fs = require './fs'
