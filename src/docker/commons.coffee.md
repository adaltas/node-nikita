# Utility function to start docker and docker-machine , check if docker-machine is installed

    mecano = require '..'

    module.exports =
      get_provider: (options, callback) ->
        mecano
        .execute
          ssh: options.ssh
          cmd: 'docker-machine -v'
          code_skipped: 127
        , (err, executed) ->
          return callback err, null if err
          if executed
            options.log message: "Provider is: docker-machine", level: 'DEBUG', module: 'mecano/docker/commons'
            return callback null,'docker-machine'
          mecano
          .execute
            ssh: options.ssh
            cmd: 'boot2docker -v'
            code_skipped: 127
          , (err, executed) ->
            return callback err,  null  if err
            provider = if executed then 'boot2docker' else 'docker'
            options.log message: "Provider is: #{provider}", level: 'DEBUG', module: 'mecano/docker/commons'
            return callback null, provider
      prepare_cmd: (provider, machine) ->
        return  Error 'Missing provider parameter' unless provider?
        return '' if provider is 'docker'
        if provider is 'boot2docker'
          return '$(boot2docker shellinit) && '
        else if provider is 'docker-machine'
          return  Error 'Missing `machine` option name. Need the name of the docker-machine' unless machine?
          return "eval \"$(docker-machine env #{machine})\" && "
        else
          return Error "Unknown docker provider: #{provider}"
      get_options: (cmd, options) ->
        exec_opts =
          cmd: cmd
        for k in ['ssh','log', 'stdout','stderr','cwd','code','code_skipped']
          exec_opts[k] = options[k] if options[k]?
        return exec_opts
