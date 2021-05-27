// Generated by CoffeeScript 2.5.1
// # `nikita.lxc.state`

// Show the current state of instances.

// ## Output parameters

// * `config` (object)   
//   Current state of the instance.

// ## Example

// ```js
// const {config} = await nikita.lxc.state({
//   container: 'container1'
// })
// console.info(config)
// ```

// ## Schema definitions
var definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      'container': {
        $ref: 'module://@nikitajs/lxd/lib/init#/definitions/config/properties/container'
      }
    },
    required: ['container']
  }
};

// ## Handler
handler = async function({config}) {
  var stdout;
  ({stdout} = (await this.execute({
    command: ['lxc', 'query', '/' + ['1.0', 'instances', config.container, 'state'].join('/')].join(' ')
  })));
  return {
    config: JSON.parse(stdout)
  };
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    definitions: definitions
  }
};

// ## Output example

// ```
// lxc query /1.0/instances/c1/state
// {
//  "cpu": {
//    "usage": 800378470122
//  },
//  "disk": {
//    "root": {
//      "usage": 1113673728
//    }
//  },
//  "memory": {
//    "swap_usage": 0,
//    "swap_usage_peak": 0,
//    "usage": 350429184,
//    "usage_peak": 386260992
//  },
//  "network": {
//    "eth0": {
//      "addresses": [
//        {
//          "address": "172.12.0.41",
//          "family": "inet",
//          "netmask": "24",
//          "scope": "global"
//        },
//        {
//          "address": "fe80::206:3eff:fefd:8b89",
//          "family": "inet6",
//          "netmask": "64",
//          "scope": "link"
//        }
//      ],
//      "counters": {
//        "bytes_received": 9711064516,
//        "bytes_sent": 335003352,
//        "packets_received": 5838218,
//        "packets_sent": 4172290
//      },
//      "host_name": "vethe703f52e",
//      "hwaddr": "00:16:3e:fc:8c:99",
//      "mtu": 1500,
//      "state": "up",
//      "type": "broadcast"
//    },
//    "eth1": {
//      "addresses": [
//        {
//          "address": "10.0.0.4",
//          "family": "inet",
//          "netmask": "24",
//          "scope": "global"
//        },
//        {
//          "address": "fe80::206:3eff:fe8b:fb64",
//          "family": "inet6",
//          "netmask": "64",
//          "scope": "link"
//        }
//      ],
//      "counters": {
//        "bytes_received": 54675771,
//        "bytes_sent": 430441929,
//        "packets_received": 316381,
//        "packets_sent": 412572
//      },
//      "host_name": "veth3eea6cae",
//      "hwaddr": "00:15:2e:9a:fb:64",
//      "mtu": 1500,
//      "state": "up",
//      "type": "broadcast"
//    },
//  },
//  "pid": 46196,
//  "processes": 47,
//  "status": "Running",
//  "status_code": 103
// }
// ```
