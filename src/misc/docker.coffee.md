
    mecano = require '..'

    module.exports.options = [
      'api-cors-header', 'bridge', 'bip', 'debug', 'daemon', 
      'default-gateway', 'default-gateway-v6', 'default-ulimit', 'dns', 
      'dns-search', 'exec-driver', 'exec-opt', 'exec-root', 'fixed-cidr', 
      'fixed-cidr-v6', 'group', 'graph', 'host', 'help', 'icc', 
      'insecure-registry', 'ip', 'ip-forward', 'ip-masq', 'iptables', 'ipv6', 
      'log-level', 'label', 'log-driver', 'log-opt', 'mtu', 'pidfile', 
      'registry-mirror', 'storage-driver', 'selinux-enabled', 'storage-opt', 
      'tls', 'tlscacert', 'tlscert', 'tlskey', 'tlsverify', 'userland-proxy', 
      'version'
    ]
    module.exports.wrap = (options, cmd) ->
      docker = {}
      docker.opts = for option in module.exports.options
        value = undefined
        if options.docker[option] then value = options.docker[option]
        else if options[option] then value = options.docker[option]
        continue unless value?
        value = 'true' if value is true
        value = 'false' if value is false
        "--#{option} #{value}"
      docker.opts = docker.opts.join ' '
      """
      export SHELL=/bin/bash
      export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
      bin_boot2docker=$(command -v boot2docker)
      bin_docker=$(command -v docker)
      bin_machine=$(command -v docker-machine)
      machine='#{options.machine or ''}'
      boot2docker='#{if options.boot2docker then '1' else ''}'
      docker=''
      if [[ $machine != '' ]] && [ $bin_machine ]; then
          if [ "#{options.machine or '--'}" = "--" ];then exit 5; fi
          if docker-machine status #{options.machine} | egrep 'Stopped|Saved'; then
            docker-machine start #{options.machine};
          fi
          docker="eval \\$(\\${bin_machine} env #{options.machine}) && $bin_docker"
      elif [[ $boot2docker != '1' ]] && [  $bin_boot2docker ]; then
          docker="eval \\$(\\${bin_boot2docker} shellinit) && $bin_docker"
      else
        docker="$bin_docker"
      fi
      eval $docker #{docker.opts} #{cmd}
      """
    module.exports.callback = (err, executed, stdout, stderr) ->
      throw Error stderr.trim().replace 'Error response from daemon: ', '' if err and /^Error response from daemon/.test stderr
