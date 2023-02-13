
# `nikita.db.database.remove`

Create a user for the destination database.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'admin_username':
            type: 'string'
            description: '''
            The login of the database administrator.
            '''
          'admin_password':
            type: 'string'
            description: '''
            The password of the database administrator.
            '''
          'database':
            type: 'string'
            description: '''
            The database name to check for existance.
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
        required: ['admin_username', 'admin_password']

## Handler

    handler = ({config}) ->
      # Avoid errors when database argument is provided in the command:
      # - Postgres: "ERROR:  cannot drop the currently open database"
      # - MariaDB: "ERROR 1049 (42000): Unknown database 'my_db'"
      await @db.query config,
        command: "DROP DATABASE IF EXISTS #{config.database};"
        code: [0, 2]
        database: null

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'database'
        global: 'db'
        definitions: definitions

## Dependencies

    {command} = require '../query'
