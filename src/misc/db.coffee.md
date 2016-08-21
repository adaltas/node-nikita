
# Misc DB

    module.exports.cmd = (opts..., cmd=null) ->
      properties = ['engine', 'admin_username', 'admin_password', 'username', 'password', 'host', 'database']
      options = {}
      for opt in opts
        for k, v of opt
          continue unless k in properties
          options[k] = v
      options.engine = options.engine.toLowerCase()
      # console.log options
      switch options.engine
        when 'mysql'
          [
            "mysql"
            "-h #{options.host}"
            "-u #{options.admin_username or options.username}"
            "-p #{options.admin_password or options.password}"
            "#{options.mysql_options}" if options.mysql_options
            "\"#{cmd}\"" if cmd
          ].join ' '
        when 'postgres'
          [
            "PGPASSWORD=#{options.admin_password or options.password}"
            "psql"
            "-h #{options.host}"
            "-U #{options.admin_username or options.username}"
            "-d #{options.database}" if options.database
            "#{options.postgres_options}" if options.postgres_options
            "-tAc \"#{cmd}\"" if cmd
          ].join ' '
        else
          throw Error "Unsupported engine: #{JSON.stringify options.engine}"
      
## Dependencies

    misc = require '.'
