
# `nikita.db.query`

Make requests to a database.

## Hooks

    on_action = ({config}) ->
      config.engine = config.engine?.toLowerCase()

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin_username':
            type: 'string'
            description: '''
            The login of the database administrator. It should have the necessary
            permissions such as to  create accounts when using the
            `nikita.db.user` action.
            '''
          'admin_password':
            type: 'string'
            description: '''
            The password of the database administrator.
            '''
          'database':
            type: ['null', 'string'],
            description: '''
            The default database name, provide the value `null` if you want to
            ensore no default database is set.
            '''
          'grep':
            oneOf: [
              type: 'string'
            ,
              instanceof: 'RegExp'
            ]
            description: '''
            Ensure the query output match a string or a regular expression
            '''
          'engine':
            type: 'string'
            enum: ['mariadb', 'mysql', 'postgresql']
            description: '''
            The engine type, can be MariaDB, MySQL or PostgreSQL. Values
            are converted to lower cases.
            '''
          'host':
            type: 'string'
            description: '''
            The hostname of the database.
            '''
          'port':
            type: 'integer'
            description: '''
            Port to the associated database.
            '''
          'silent':
            type: 'boolean'
            default: true
          'trim':
            type: 'boolean'
            default: false
        required: [
          'admin_password', 'command'
          'engine', 'host', 'admin_username'
        ]

## Handler

    handler = ({config}) ->
      {$status, stdout} = await @execute
        command: utils.db.command config
        trim: config.trim
      if config.grep and typeof config.grep is 'string'
        return stdout: stdout, $status: stdout.split('\n').some (line) -> line is config.grep
      if config.grep and utils.regexp.is config.grep
        return stdout: stdout, $status: stdout.split('\n').some (line) -> config.grep.test line
      status: $status, stdout: stdout

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        global: 'db'
        definitions: definitions

## Dependencies

    utils = require './utils'
