
// Dependencies
import path from 'node:path'
import {merge} from 'mixme';
import utils from "@nikitajs/system/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.mounts ??= []
    config.groups ??= {};
    config.merge ??= true;
    config.cgconfig = {};
    config.cgconfig['mounts'] = config.mounts;
    config.cgconfig['groups'] = config.groups;
    if (config.default != null) {
      config.cgconfig['groups'][''] = config.default;
    }
    if (config.ignore == null) {
      config.ignore = [];
    }
    if (!Array.isArray(config.ignore)) {
      config.ignore = [config.ignore];
    }
    // Detect Os and version
    const {os} = await this.system.info.os();
    // configure parameters based on previous OS dection
    const store = {};
    // Enable cgroup for all distribution, it was restricted to rhel systems
    // if ['redhat','centos'].includes os.distribution
    if (true) {
      const {stdout} = await this.execute({
        $shy: true,
        command: 'cgsnapshot -s 2>&1'
      });
      const cgconfig = utils.cgconfig.parse(stdout);
      if (cgconfig.mounts == null) {
        cgconfig.mounts = [];
      }
      const cpus = cgconfig.mounts.filter(function(mount) {
        return mount.type === 'cpu';
      });
      // const cpuaccts = cgconfig.mounts.filter(function(mount) {
      //   return mount.type === 'cpuacct';
      // });
      // We choose a path which is mounted by default
      // if not @store['nikita:cgroups:cpu_path']?
      if (cpus.length > 0) {
        store.cpu_path = cpus[0]['path'].split(',')[0];
      } else {
        // @store['nikita:cgroups:cpu_path'] ?= cpu_path
        // a arbitrary path is given based on the
        switch (os.distribution) {
          case 'redhat':
          case 'centos':
            const majorVersion = os.version.split('.')[0];
            switch (majorVersion) {
              case '6':
                store.cpu_path = '/cgroups/cpu';
                break;
              case '7':
                store.cpu_path = '/sys/fs/cgroup/cpu';
                break;
              default:
                throw Error("Nikita does not support cgroups for your RedHat or CentOS version}");
            }
            break;
          default:
            throw Error(`Nikita does not support cgroups on your OS ${os.distribution}`);
        }
      }
      store.mount = `${path.posix.dirname(store.cpu_path)}`;
      // Running docker containers are remove from cgsnapshot output
      if (config.merge) {
        const groups = {};
        for (const name in cgconfig.groups) {
          if (!(name.includes('docker/') || config.ignore.includes(name))) {
            groups[name] = cgconfig.groups[name];
          }
        }
        config.cgconfig.groups = merge(groups, config.groups);
        config.cgconfig.mounts.push(...cgconfig.mounts);
      }
    }
    if (['redhat', 'centos'].includes(os.distribution)) {
      // Write the configuration
      if (config.target == null) {
        config.target = '/etc/cgconfig.conf';
      }
    }
    await this.file({
      target: config.target,
      content: utils.cgconfig.stringify(config.cgconfig)
    });
    return {
      cgroups: {
        cpu_path: store.cpu_path,
        mount: store.mount
      }
    };
  },
  metadata: {
    definitions: definitions
  }
};
