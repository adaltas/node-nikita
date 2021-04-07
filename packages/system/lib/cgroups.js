// Generated by CoffeeScript 2.5.1
  // # `nikita.system.cgroups`

// Nikita action to manipulate cgroups. [cgconfig.conf(5)] describes the 
  // configuration file used by libcgroup to define control groups, their parameters 
  // and also mount points. The configuration file is identical on Ubuntu, RedHat 
  // and CentOS.

// ## Implementation

// When reading the current config, nikita uses `cgsnapshot` command in order to
  // have a well formatted file. It is available on CentOS with the `libcgroup-tools`
  // package.

// If docker is installed and started, informations about live containers could be
  // printed, that's why all path under  docker/* are ignored.

// ## Example

// Example of a group object:

// ```cson
  // bibi:
  //   perm:
  //     admin:
  //       uid: 'bibi'
  //       gid: 'bibi'
  //     task:
  //       uid: 'bibi'
  //       gid: 'bibi'
  //   controllers:
  //     cpu:
  //       'cpu.rt_period_us': '"1000000"'
  //       'cpu.rt_runtime_us': '"0"'
  //       'cpu.cfs_period_us': '"100000"'
  // ```

// Which will result in a file:

// ```text
  // group bibi {
  //   perm {
  //     admin {
  //       uid = bibi;
  //       gid = bibi;
  //     }
  //     task {
  //       uid = bibi;
  //       gid = bibi;
  //     }
  //   }
  //   cpu {
  //     cpu.rt_period_us = "1000000";
  //     cpu.rt_runtime_us = "0";
  //     cpu.cfs_period_us = "100000";
  //   }
  // }
  // ```

// ## Schema
var handler, merge, path, schema, utils,
  indexOf = [].indexOf;

schema = {
  config: {
    type: 'object',
    properties: {
      'default': {
        $ref: '#/definitions/group',
        description: `The default object of cgconfig file.`
      },
      'groups': {
        type: 'object',
        description: `Object of cgroups to add to cgconfig file. The keys are the
cgroup name, and the values are the cgroup configuration.`,
        patternProperties: {
          '.*': { // cgroup name
            $ref: '#/definitions/group'
          }
        },
        additionalProperties: false
      },
      'ignore': {
        type: 'array',
        items: {
          type: 'string'
        },
        description: `List of group path to ignore. Only used when merging.`
      },
      'mounts': {
        type: 'array',
        description: `List of mount object to add to cgconfig file.`
      },
      'merge': {
        type: 'boolean',
        default: true,
        description: `Default to true. Read the config from cgsnapshot command and merge
mounts part of the cgroups.`
      },
      'target': {
        type: 'string',
        description: `The cgconfig configuration file. By default nikita detects provider
based on  os.`
      }
    },
    anyOf: [
      {
        required: ['groups']
      },
      {
        required: ['mounts']
      },
      {
        required: ['default']
      }
    ]
  },
  group: {
    type: 'object',
    description: `Controllers in the cgroup where the keys represent the name of the
controler.`,
    properties: {
      perm: {
        type: 'object',
        description: `Object to describe the taks and limits permissions.`,
        properties: {
          'admin': {
            $ref: '#/definitions/group_perm',
            description: `Who can manage limits`
          },
          'task': {
            $ref: '#/definitions/group_perm',
            description: `Who can add tasks to this group`
          }
        }
      },
      cpuset: {
        $ref: '#/definitions/group_controller'
      },
      cpu: {
        $ref: '#/definitions/group_controller'
      },
      cpuacct: {
        $ref: '#/definitions/group_controller'
      },
      blkio: {
        $ref: '#/definitions/group_controller'
      },
      memory: {
        $ref: '#/definitions/group_controller'
      },
      devices: {
        $ref: '#/definitions/group_controller'
      },
      freezer: {
        $ref: '#/definitions/group_controller'
      },
      net_cls: {
        $ref: '#/definitions/group_controller'
      },
      perf_event: {
        $ref: '#/definitions/group_controller'
      },
      net_prio: {
        $ref: '#/definitions/group_controller'
      },
      hugetlb: {
        $ref: '#/definitions/group_controller'
      },
      pids: {
        $ref: '#/definitions/group_controller'
      },
      rdma: {
        $ref: '#/definitions/group_controller'
      }
    }
  },
  group_perm: {
    type: 'object',
    properties: {
      'uid': {
        oneOf: [
          {
            type: 'integer'
          },
          {
            type: 'string'
          }
        ]
      },
      'gid': {
        oneOf: [
          {
            type: 'integer'
          },
          {
            type: 'string'
          }
        ]
      }
    }
  },
  group_controller: {
    type: 'object',
    patternProperties: {
      '.*': {
        oneOf: [
          {
            type: 'integer'
          },
          {
            type: 'string'
          }
        ]
      }
    },
    additionalProperties: false
  }
};

// ## Handler
handler = async function({config}) {
  var cgconfig, cpuaccts, cpus, group, groups, majorVersion, name, os, ref, stdout, store;
  // throw Error 'Missing cgroups content' unless config.groups? or config.mounts? or config.default?
  if (config.mounts == null) {
    config.mounts = [];
  }
  if (config.groups == null) {
    config.groups = {};
  }
  if (config.merge == null) {
    config.merge = true;
  }
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
  ({os} = (await this.system.info.os()));
  // configure parameters based on previous OS dection
  store = {};
  if (['redhat', 'centos'].includes(os.distribution)) {
    ({stdout} = (await this.execute({
      $shy: true,
      command: 'cgsnapshot -s 2>&1'
    })));
    cgconfig = utils.cgconfig.parse(stdout);
    if (cgconfig.mounts == null) {
      cgconfig.mounts = [];
    }
    cpus = cgconfig.mounts.filter(function(mount) {
      return mount.type === 'cpu';
    });
    cpuaccts = cgconfig.mounts.filter(function(mount) {
      return mount.type === 'cpuacct';
    });
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
          majorVersion = os.version.split('.')[0];
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
      groups = {};
      ref = cgconfig.groups;
      for (name in ref) {
        group = ref[name];
        if (!((name.indexOf('docker/') !== -1) || (indexOf.call(config.ignore, name) >= 0))) {
          groups[name] = group;
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
  this.file(config, {
    content: utils.cgconfig.stringify(config.cgconfig)
  });
  return {
    cgroups: {
      cpu_path: store.cpu_path,
      mount: store.mount
    }
  };
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    schema: schema
  }
};

// ## Dependencies
utils = require('./utils');

({merge} = require('mixme'));

path = require('path');

// [cgconfig.conf(5)]: https://linux.die.net/man/5/cgconfig.conf
