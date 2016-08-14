
    mecano = require '..'
    
    module.exports.wrap = (options={}) ->
      
      options.engine ?= 'POSTGRES'
      options.engine = options.engine.toUpperCase()
      # We set user and password from admin_username/admin_password for shortening call options.
      # options.user = options.admin_username if  options.admin_username?
      # options.password = options.admin_password if  options.admin_password?
      return Error 'Mssing name/password' unless options.name? or options.password?
      cmd = ''
      switch options.engine
        when 'MYSQL'
          cmd += "mysql -h #{options.host} -u #{options.name} -p #{options.password} "
          cmd += "-d #{db}" if options.database
          return cmd
          break;
        when 'POSTGRES'
          cmd += "PGPASSWORD=#{options.password} psql -h #{options.host} -U #{options.name} "
          cmd += "-d #{db}" if options.database
          return cmd
          break;
      return cmd
          
