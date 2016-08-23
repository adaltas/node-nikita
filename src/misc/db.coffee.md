
# Misc DB

    module.exports.cmd = (opts..., cmd=null) ->
      properties = ['engine', 'admin_username', 'admin_password', 'username', 'password', 'host', 'database']
      options = {}
      for opt in opts
        for k, v of opt
          continue unless k in properties
          options[k] = v
      options.engine = options.engine.toLowerCase()
      options.admin_password = null unless options.admin_username
      # console.log options
      switch options.engine
        when 'mysql'
          [
            "mysql"
            "-h#{options.host}"
            "-u#{options.admin_username or options.username}"
            "-p#{options.admin_password or options.password}"
            "-D#{options.database}" if options.database
            "#{options.mysql_options}" if options.mysql_options
            # -N, --skip-column-names   Don't write column names in results.
            # -s, --silent              Be more silent. Print results with a tab as separator, each row on new line.
            # -r, --raw                 Write fields without conversion. Used with --batch.
            "-N -s -r"
            "-e \"#{cmd}\"" if cmd
          ].join ' '
        when 'postgres'
          [
            "PGPASSWORD=#{options.admin_password or options.password}"
            "psql"
            "-h #{options.host}"
            "-U #{options.admin_username or options.username}"
            "-d #{options.database}" if options.database
            "#{options.postgres_options}" if options.postgres_options
            # -t, --tuples-only        Print rows only
            # -A, --no-align           Unaligned table output mode
            # -q, --quiet              Run quietly (no messages, only query output)
            "-tAq"
            "-c \"#{cmd}\"" if cmd
          ].join ' '
        else
          throw Error "Unsupported engine: #{JSON.stringify options.engine}"
      
## Dependencies

    misc = require '.'
