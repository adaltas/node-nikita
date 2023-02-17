utils = require '@nikitajs/core/lib/utils'

module.exports = {
  ...utils
  db: 
    # Escape SQL for Bash processing.
    escape: (sql) ->
      sql.replace /[\\"]/g, "\\$&"
    # Build the CLI query command.
    command : (...opts) ->
      config = {}
      for opt in opts
        opt = command: opt if typeof opt is 'string'
        for k, v of opt
          config[k] = v
      switch config.engine
        when 'mariadb', 'mysql'
          config.path ?= 'mysql'
          config.port ?= '3306'
          [
            "#{config.path}"
            "-h#{config.host}"
            "-P#{config.port}"
            "-u#{config.admin_username}"
            "-p'#{config.admin_password}'"
            "-D#{config.database}" if config.database
            "#{config.mysql_config}" if config.mysql_config
            # -N, --skip-column-names   Don't write column names in results.
            # -s, --silent              Be more silent. Print results with a tab as separator, each row on new line.
            # -r, --raw                 Write fields without conversion. Used with --batch.
            "-N -s -r" if config.silent
            "-e \"#{module.exports.db.escape config.command}\"" if config.command
          ].filter Boolean
          .join ' '
        when 'postgresql'
          config.path ?= 'psql'
          config.port ?= '5432'
          [
            "PGPASSWORD=#{config.admin_password}"
            "#{config.path}"
            "-h #{config.host}"
            "-p #{config.port}"
            "-U #{config.admin_username}"
            "-d #{config.database}" if config.database
            "#{config.postgres_config}" if config.postgres_config
            # -t, --tuples-only        Print rows only
            # -A, --no-align           Unaligned table output mode
            # -q, --quiet              Run quietly (no messages, only query output)
            "-tAq"
            "-c \"#{config.command}\"" if config.command
          ].filter Boolean
          .join ' '
        else
          throw Error "Unsupported engine: #{JSON.stringify config.engine}"
    ###
    Parse JDBC URL
    
    Enrich the result of `url.parse` with the "engine" and "db" properties.
    
    Example:
    
    ```
    parse 'jdbc:mysql://host1:3306,host2:3306/hive?createDatabaseIfNotExist=true'
    { engine: 'mysql',
      addresses:
       [ { host: 'host1', port: '3306' },
         { host: 'host2', port: '3306' } ],
      database: 'hive' }
    ```
    ###
    jdbc: (jdbc) ->
      if /^jdbc:mysql:/.test jdbc
        [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec jdbc
        addresses = addresses.split(',').map (address) ->
          [host, port] = address.split ':'
          host: host, port: port or 3306
        engine: 'mysql'
        addresses: addresses
        database: database
      else if /^jdbc:postgresql:/.test jdbc
        [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec jdbc
        addresses = addresses.split(',').map (address) ->
          [host, port] = address.split ':'
          host: host, port: port or 5432
        engine: 'postgresql'
        addresses: addresses
        database: database
      else
        throw Error 'Invalid JDBC URL'
    ## Filter connection properties
    connection_config: (opts) ->
      config = {}
      for k, v of opts
        continue unless k in ['admin_username', 'admin_password', 'database', 'engine', 'host', 'port', 'silent']
        config[k] = v
      config
}
