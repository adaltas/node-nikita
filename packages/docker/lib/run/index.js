// Dependencies
import definitions from "./schema.json" assert { type: "json" };
import utils from "@nikitajs/docker/utils";

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (!(config.name != null || config.rm)) {
      log("WARN", "Should specify a container name if rm is false");
    }
    // Construct exec command
    let command = "run";
    const optMapValString = {
      name: "--name",
      hostname: "-h",
      cpu_shares: "-c",
      cgroup_parent: "--cgroup-parent",
      cid_file: "--cidfile",
      blkio_weight: "--blkio-weight",
      cpuset_cpus: "--cpuset-cpus",
      entrypoint: "--entrypoint",
      ipc: "--ipc",
      log_driver: "--log-driver",
      memory: "-m",
      mac_address: "--mac-address",
      memory_swap: "--memory-swap",
      net: "--net",
      pid: "--pid",
      cwd: "-w",
    };
    // Classic config
    for (const opt in optMapValString) {
      const flag = optMapValString[opt];
      if (config[opt] != null) {
        command += ` ${flag} ${config[opt]}`;
      }
    }
    if (config.detach) {
      // else ' -t'
      command += " -d";
    }
    const optMapValBoolean = {
      rm: "--rm",
      publish_all: "-P",
      privileged: "--privileged",
      read_only: "--read-only",
    };
    // Flag config
    for (const opt in optMapValBoolean) {
      const flag = optMapValBoolean[opt];
      if (config[opt]) {
        command += ` ${flag}`;
      }
    }
    const optMapValArray = {
      port: "-p",
      volume: "-v",
      device: "--device",
      label: "-l",
      label_file: "--label-file",
      expose: "--expose",
      env: "-e",
      env_file: "--env-file",
      dns: "--dns",
      dns_search: "--dns-search",
      volumes_from: "--volumes-from",
      cap_add: "--cap-add",
      cap_drop: "--cap-drop",
      ulimit: "--ulimit",
      add_host: "--add-host",
    };
    // Arrays config
    for (const opt in optMapValArray) {
      const flag = optMapValArray[opt];
      const values = config[opt];
      if (values == null) {
        continue;
      }
      if (typeof values === "string" || typeof values === "number") {
        command += ` ${flag} ${values}`;
      } else if (Array.isArray(values)) {
        for (const value of values) {
          if (typeof value === "string" || typeof value === "number") {
            command += ` ${flag} ${value}`;
          } else {
            throw utils.error("NIKITA_DOCKER_RUN_INVALID_VALUE", [
              `${JSON.stringify(
                opt
              )} array should only contains string or numberl`,
            ]);
          }
        }
      } else {
        throw utils.error("NIKITA_DOCKER_RUN_INVALID_VALUES", [
          `${JSON.stringify(opt)} should be string, number or array.`,
        ]);
      }
    }
    command += ` ${config.image}`;
    if (config.command) {
      command += ` ${config.command}`;
    }
    // need to delete the command config or it will be used in docker.exec
    // delete config.command
    const { $status } = await this.docker.tools.execute({
      $if: config.name != null,
      $shy: true,
      command: `ps -a | egrep ' ${config.name}$'`,
      code: [0, 1],
    });
    if ($status) {
      log("Container already running. Skipping");
    }
    const result = await this.docker.tools.execute({
      $if: config.name == null || $status === false,
      command: command,
    });
    if (result.$status) {
      log("WARN", "Container now running");
    }
    return result;
  },
  hooks: {
    on_action: function ({ config }) {
      // throw Error 'Property "container" no longer exists' if config.container
      // config.name = config.container if not config.name? and config.container?
      if (config.name == null) {
        config.name = config.container;
      }
      if (typeof config.expose === "string") {
        return (config.expose = parseInt(config.expose));
      }
    },
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
