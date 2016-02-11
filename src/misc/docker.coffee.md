
    mecano = require '..'

    module.exports.wrap = (options, cmd) ->
      """
      export SHELL=/bin/bash
      export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
      bin_boot2docker=$(command -v boot2docker)
      bin_docker=$(command -v docker)
      bin_machine=$(command -v docker-machine)
      docker=''
      if [ $bin_machine ]; then
          if [ "#{options.machine or '--'}" = "--" ];then exit 5; fi
          docker="eval \\$(\\${bin_machine} env #{options.machine}) && $bin_docker"
      elif [  $bin_boot2docker ]; then
          docker="eval \\$(\\${bin_boot2docker} shellinit) && $bin_docker"
      else
        docker="$bin_docker"
      fi
      eval $docker #{cmd}
      """
    module.exports.callback = (callback, err, executed, stdout, stderr) ->
      return callback Error stderr.trim().replace 'Error response from daemon: ', '' if err
      return callback err, executed, stdout, stderr
