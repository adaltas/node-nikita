
# `nikita.db.user.remove`

Remove a user for the destination database.

## Schema

    schema =
      type: 'object'
      properties:
        'username':
          type: 'string'
          description: '''
          The name of the user to remove.
          '''
      required: [
        'username'
        'admin_username', 'admin_password', 'engine', 'host'
      ]

## Handler

    handler = ({config}) ->
      await @db.query config,
        command: "DROP USER IF EXISTS #{config.username};"

## Exports

    module.exports =
      handler: handler
      metadata:
        argument_to_config: 'username'
        global: 'db'
        schema: schema

## Dependencies

    {command} = require '../query'
