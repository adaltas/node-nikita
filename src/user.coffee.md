(goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments, parallel: true
      result = child mecano
      finish = (err, gmodified) ->
        callback err, gmodified if callback
        result.end err, gmodified
      misc.options options, (err, options) ->
        return finish err if err
        gmodified = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          return next new Error "Option 'username' is required" unless options.username
          options.comment ?= ""
          # options.home ?= "/home/#{options.username}"
          # options.shell ?= "/sbin/nologin"
          options.shell = "/sbin/nologin" if options.shell is false
          options.shell = "/bin/bash" if options.shell is true
          options.system ?= false
          options.gid ?= null
          return next new Error "Invalid option 'shell': #{JSON.strinfigy options.shell}" if options.shell? typeof options.shell isnt 'string'
          modified = false
          info = null
          do_info = ->
            options.log? "Get user information for #{options.username}"
            options.ssh?.passwd = null # Clear cache if any 
            misc.ssh.passwd options.ssh, (err, users) ->
              return next err if err
              options.log? "Got #{JSON.stringify users[options.username]}"
              info = users[options.username]
              if info then do_compare() else do_create()
          do_create = ->
            cmd = 'useradd'
            cmd += " -r" if options.system
            cmd += " -M" unless options.home
            cmd += " -d #{options.home}" if options.home
            cmd += " -s #{options.shell}" if options.shell
            cmd += " -c #{JSON.stringify options.comment}" if options.comment
            cmd += " -u #{options.uid}" if options.uid
            cmd += " -g #{options.gid}" if options.gid
            cmd += " #{options.username}"
            mecano.execute
              ssh: options.ssh
              cmd: cmd
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err) ->
              modified = true unless err
              next err
          do_compare = ->
            for k in ['home', 'shell', 'comment', 'gid']
              modified = true if info[k] isnt options[k]
            options.log? "Did user information changed: #{modified}"
            if modified then do_modify() else next()
          do_modify = ->
            cmd = 'usermod'
            cmd += " -d #{options.home}" if options.home
            cmd += " -s #{options.shell}" if options.shell
            cmd += " -c #{options.comment}" if options.comment
            cmd += " -g #{options.gid}" if options.gid
            cmd += " #{options.username}"
            mecano.execute
              ssh: options.ssh
              cmd: cmd
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err) ->
              return next err
          do_info()
        .on 'both', (err) ->
          finish err, gmodified
      result