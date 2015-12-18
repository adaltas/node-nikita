
    mecano = require '..'

    module.exports.wrap = (options, cmd) ->
      """
      export SHELL=/bin/bash
      export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
      bin_boot2docker=$(command -v boot2docker)
      bin_docker=$(command -v docker)
      bin_machine=$(command -v docker-machine)
      if [ $bin_machine ]; then
          if [ \"#{options.machine or '--'}\" = \"--\" ];then exit 5; fi
          eval $(${bin_machine} env #{options.machine}) && $bin_docker #{cmd}
      elif [  $bin_boot2docker ]; then
          eval $(${bin_boot2docker} shellinit) && $bin_docker #{cmd}
      else
        $bin_docker #{cmd}
      fi
      """
