
# Misc DB

    module.exports.cmd = (options..., cmd) ->
      options = misc.merge options...
      options.engine = options.engine.toLowerCase()
      switch options.engine
        when 'mysql'
          [
            "mysql"
            "-h #{options.host}"
            "-u #{options.admin_username or options.name}"
            "-p #{options.admin_password or options.password}"
            "\"#{cmd}\""
          ].join ' '
        when 'postgres'
          [
            "PGPASSWORD=#{options.admin_password or options.password}"
            "psql"
            "-h #{options.host}"
            "-U #{options.admin_username or options.name}"
            "-tAc \"#{cmd}\""
          ].join ' '
        else
          throw Error "Unsupported engine: #{JSON.stringify options.engine}"
      
## Dependencies

    misc = require '.'
