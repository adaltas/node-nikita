
    mecano = require '..'
    
    module.exports.wrap = (options, cmd) ->
      """
      export SHELL=/bin/bash
      export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
      bin_boot2docker=$(command -v boot2docker)
      bin_docker=$(command -v docker)
      bin_machine=$(command -v docker-machine)
      if [ $bin_machine ]; then
          if [ \"#{options.machine or '--'}\" = \"--\" ];then exit 5;fi
          eval $(${bin_machine} env #{options.machine}) && $bin_docker #{cmd}
      elif [  $bin_boot2docker ]; then
          eval $(${bin_boot2docker} shellinit) && $bin_docker #{cmd}
      else
        $bin_docker #{cmd}
      fi
      """

    module.exports.exec = (comand, options, ignore_code, callback) ->

      options.log message: "Docker exec: docker #{comand}", level: 'DEBUG', module: 'mecano/lib/misc/docker' if options.log
      machine = options.machine ?= '--'
      options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
      options.code_skipped.push(1) if ignore_code
      cmd = """
        export SHELL=/bin/bash
        export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
        bin_boot2docker=$(command -v boot2docker)
        bin_docker=$(command -v docker)
        bin_machine=$(command -v docker-machine)
        if [ $bin_machine ];
          then
            if [ \"#{machine}\" = \"--\" ];then exit 5;fi
            eval $(${bin_machine} env #{machine}) && $bin_docker #{comand}
        elif [  $bin_boot2docker ];
          then
            eval $(${bin_boot2docker} shellinit) && $bin_docker #{comand}
        else
          $bin_docker #{comand}
        fi
        """
      opts = @get_options cmd, options
      mecano
      .execute opts,  (err, executed, stdout, stderr) ->
        if err
          return callback Error('Missing machine name as options') if err.code == 5
        return callback err, executed, stdout, stderr

    module.exports.get_options = (cmd, options) ->
      exec_opts =
        cmd: cmd
      for k in ['ssh','log', 'stdout','stderr','cwd','code','code_skipped',
      'machine', 'force', 'container', 'image','entrypoint','trap_on_error','port','cmd']
        exec_opts[k] = options[k] if options[k]?
      return exec_opts
