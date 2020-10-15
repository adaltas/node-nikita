
# `nikita.db.user`

Create a user for the destination database.

## Schema

    schema =
      type: 'object'
      properties:
        'username':
          type: 'string'
          description: """
          The username of a user with privileges on the database, used unless admin_username is provided.
          """
        'password':
          type: 'string'
          description: """
          The password of a user with privileges on the database, used unless admin_password is provided.
          """
        'admin_username':
          $ref: 'module://@nikitajs/db/src/query#/properties/admin_username'
        'admin_password':
          $ref: 'module://@nikitajs/db/src/query#/properties/admin_password'
        'engine':
          $ref: 'module://@nikitajs/db/src/query#/properties/engine'
        'host':
          $ref: 'module://@nikitajs/db/src/query#/properties/host'
        'port':
          $ref: 'module://@nikitajs/db/src/query#/properties/port'
      required: [
        'username', 'password'
        'admin_username', 'admin_password', 'engine', 'host'
      ]

## Hander

    handler = ({config}) ->
      # Commands
      switch config.engine
        when 'mariadb', 'mysql'
          cmd_user_exists = cmd(config, "SELECT User FROM mysql.user WHERE User='#{config.username}'") + " | grep #{config.username}"
          cmd_user_create = cmd config, "CREATE USER #{config.username} IDENTIFIED BY '#{config.password}';"
          cmd_password_is_invalid = cmd(config, admin_username: config.username, admin_password: config.password, '\\dt') + " 2>&1 >/dev/null | grep -e '^ERROR 1045.*'"
          cmd_password_change = cmd config, "SET PASSWORD FOR #{config.username} = PASSWORD ('#{config.password}');"
        when 'postgresql'
          cmd_user_exists = cmd(config, "SELECT 1 FROM pg_roles WHERE rolname='#{config.username}'") + " | grep 1"
          cmd_user_create = cmd config, "CREATE USER #{config.username} WITH PASSWORD '#{config.password}';"
          cmd_password_is_invalid = cmd(config, admin_username: config.username, admin_password: config.password, '\\dt') + " 2>&1 >/dev/null | grep -e '^psql:\\sFATAL.*password\\sauthentication\\sfailed\\sfor\\suser.*'"
          cmd_password_change = cmd config, "ALTER USER #{config.username} WITH PASSWORD '#{config.password}';"
      @execute
        cmd: """
        signal=3
        if #{cmd_user_exists}; then
          echo '[INFO] User already exists'
        else
          #{cmd_user_create}
          echo '[WARN] User created'
          signal=0
        fi
        if [ $signal -eq 3 ]; then
          if ! #{cmd_password_is_invalid}; then
            echo '[INFO] Password not modified'
          else
            #{cmd_password_change}
            echo '[WARN] Password modified'
            signal=0
          fi
        fi
        exit $signal
        """
        code_skipped: 3
        trap: true

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'db'
      schema: schema

## Dependencies

    {cmd} = require '../query'
