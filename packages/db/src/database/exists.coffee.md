
# `nikita.db.database.exists`

Check if a database exists.

## Schema

    schema =
      type: 'object'
      properties:
        'admin_username':
          $ref: 'module://@nikitajs/db/src/query#/properties/admin_username'
        'admin_password':
          $ref: 'module://@nikitajs/db/src/query#/properties/admin_password'
        'database':
          type: 'string'
          description: """
          The database name to check for existance.
          """
        'engine':
          $ref: 'module://@nikitajs/db/src/query#/properties/engine'
        'host':
          $ref: 'module://@nikitajs/db/src/query#/properties/host'
        'port':
          $ref: 'module://@nikitajs/db/src/query#/properties/port'
      required: ['admin_username', 'admin_password', 'database', 'engine', 'host']

## Handler

    handler = ({config}) ->
      {status} = await @db.query connection_config(config),
        command: switch config.engine
          when 'mariadb', 'mysql'
            'SHOW DATABASES'
          when 'postgresql'
            # Not sure why we're not using \l
            "SELECT datname FROM pg_database WHERE datname = '#{config.database}'"
        database: null
        grep: config.database
      exists: status

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_name: 'database'
        global: 'db'
        shy: true
      schema: schema

## Dependencies

    {command, connection_config} = require '../query'
