
# `nikita.file.ini.read`

Read an .ini file and convert it to a JavaScript object.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'encoding':
            type: 'string'
            default: 'utf8'
            description: '''
            File encoding.
            '''
          'parse':
            typeof: 'function'
            description: '''
            User-defined function to parse the content from ini format, default to
            `require('ini').parse`, see
            'nikita.file.utils.ini.parse\_multi\_brackets'. '''
          'target':
            type: 'string'
            description: '''
            Path to a ini file to read.
            '''
        required: ['target']

## Handler

    handler = ({config}) ->
      parse = config.parse or utils.ini.parse
      {data} = await @fs.base.readFile
        target: config.target
        encoding: config.encoding
      data: merge parse data, config
      

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
    {merge} = require 'mixme'
