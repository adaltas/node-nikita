import dedent from 'dedent';

const options = [
  "api-cors-header",
  "bridge",
  "bip",
  "debug",
  "daemon",
  "default-gateway",
  "default-gateway-v6",
  "default-ulimit",
  "dns",
  "dns-search",
  "exec-driver",
  "exec-opt",
  "exec-root",
  "fixed-cidr",
  "fixed-cidr-v6",
  "group",
  "graph",
  "host",
  "help",
  "icc",
  "insecure-registry",
  "ip",
  "ip-forward",
  "ip-masq",
  "iptables",
  "ipv6",
  "log-level",
  "label",
  "log-driver",
  "log-opt",
  "mtu",
  "pidfile",
  "registry-mirror",
  "storage-driver",
  "selinux-enabled",
  "storage-opt",
  "tls",
  "tlscacert",
  "tlscert",
  "tlskey",
  "tlsverify",
  "userland-proxy",
  "version",
];

const compose_options = [
  "file",
  "project-name",
  "verbose",
  "no-ansi",
  "version",
  "host",
  // TLS
  "tls",
  "tlscacert",
  "tlscert",
  "tlskey",
  "tlsverify",
  "skip-hostname-check",
  "project-directory",
];

const opts = function (config) {
  const opts = (function () {
    const results = [];
    for (const option in !config.compose ? options : compose_options) {
      let value = config[option];
      if (value == null) {
        continue;
      }
      if (value === true) {
        value = "true";
      }
      if (value === false) {
        value = "false";
      }
      if (option === "tlsverify") {
        results.push(`--${option}`);
      } else {
        results.push(`--${option}=${value}`);
      }
    }
    return results;
  })();
  return opts.join(" ");
};

/*
Build the docker command
Accepted options are referenced in the `options` property. Also accept
"machine" and "boot2docker".
`compose` option allow to wrap the command for docker-compose instead of docker
*/
const wrap = function (config, command) {
  const options = opts(config);
  const exe = config.compose ? "bin_compose" : "bin_docker";
  return dedent`
    export SHELL=/bin/bash
    export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
    bin_boot2docker=$(command -v boot2docker)
    bin_docker=$(command -v docker)
    bin_machine=$(command -v docker-machine)
    bin_compose=$(command -v docker-compose)
    machine='${config.machine || ""}'
    boot2docker='${config.boot2docker ? "1" : ""}'
    docker=''
    if [[ $machine != '' ]] && [ $bin_machine ]; then
    if [ -z "${config.machine || ""}" ]; then exit 5; fi
    if docker-machine status "\${machine}" | egrep 'Stopped|Saved'; then
      docker-machine start "\${machine}";
    fi
    #docker="eval \\$(\\\${bin_machine} env \${machine}) && $${exe}"
    eval "$(\${bin_machine} env \${machine})"
    elif [[ $boot2docker != '1' ]] && [  $bin_boot2docker ]; then
    #docker="eval \\$(\\\${bin_boot2docker} shellinit) && $${exe}"
    eval "$(\${bin_boot2docker} shellinit)"
    fi
    $${exe} ${options} ${command}
  `;
};

export { options, compose_options, opts, wrap };

export default {
  options: options,
  compose_options: compose_options,
  opts: opts,
  wrap: wrap,
};
