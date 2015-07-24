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
            options.log? "provider is: docker-machine [DEBUG]"
            return callback null,'docker-machine'
          mecano
          .execute
            ssh: options.ssh
            cmd: 'boot2docker -v'
            code_skipped: 127
          , (err, executed) ->
            return callback err,  null  if err
            provider = if executed then 'boot2docker' else 'docker'
            options.log? "provider is: #{provider} [DEBUG]"
            return callback null, provider
      prepare_cmd: (provider, machine) ->
        return  Error 'Missing provider parameter' unless provider?
        return '' if provider is 'docker'
        return  Error 'Missing `machine` option name. Need the name of the docker-machine' unless machine?
        if provider is 'docker-machine'
          return "eval \"$(docker-machine env #{machine})\" && "
        else if provider is 'boot2docker'
          return '$(boot2docker shellinit) && '
        else
          return callback Error "Unknown docker provider: #{provider}"
      # start_docker_daemon: (options, callback) ->
        # return callback Error 'missing docker provider ' unless options.provider?
        # switch options.provider
          # when 'docker-machine'
            # mecano
              # .execute
                # ssh: options.ssh
                # cmd: 'docker-machine start'
              # .then callback null
          # when 'docker-machine'
            # mecano
              # .execute
                # ssh: options.ssh
                # cmd: 'boot2docker start'
              # .then callback null
          # else
            # mecano
              # .execute
                # ssh: options.ssh
                # cmd: 'service docker start'
              # .then callback null
