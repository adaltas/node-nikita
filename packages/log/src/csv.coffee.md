
# `nikita.log.csv`

Write log to the host filesystem in CSV.

## Config

* `archive` (boolean)   
  Save a copy of the previous logs inside a dedicated directory, default is
  "false".   
* `basedir` (string)    
  Directory where to store logs relative to the process working directory.
  Default to the "log" directory. Note, if the "archive" option is activated
  log file will be stored accessible from "./log/latest".   
* `filename` (string)   
  Name of the log file, contextually rendered with all config passed to
  the mustache templating engine. Default to "{{shortname}}.log", where 
  "shortname" is the ssh host or localhost.   

Global config can be alternatively set with the "log_csv" property.

## Schema

    schema =
      config:
        type: 'object'
        allOf: [
          properties:
            serializer:
              type: 'object'
              default: {}
              description: '''
              Internal property, expose access to the serializer object passed
              to the `log.fs` action.
              '''
        ,
          $ref: 'module://@nikitajs/log/src/fs#/definitions/config'
        ]

## Handler

    handler = ({config}) ->
      serializer =
        'nikita:action:start': ({action}) ->
          return unless action.metadata.header
          walk = (parent) ->
            precious = parent.metadata.header
            results = []
            results.push precious unless precious is undefined
            results.push ...(walk parent.parent) if parent.parent
            results
          headers = walk action
          header = headers.reverse().join ' : '
          "header,,#{JSON.stringify header}\n"
        'text': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message}\n"
      config.serializer = merge serializer, config.serializer
      @log.fs config

## Exports

    module.exports =
      # ssh: false
      handler: handler
      metadata:
        schema: schema

## Dependencies

    {merge} = require 'mixme'
