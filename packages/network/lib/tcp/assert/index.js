
// Dependencies
const definitions = require('./schema.json');

// on_action = function({config}) {
//   var extract_servers, i, len, ref, srv, srvs;
//   if (config.server) {
//     if (Array.isArray(config.server)) {
//       config.server = utils.array.flatten(config.server);
//     } else {
//       config.server = [config.server];
//     }
//   }
//   extract_servers = function(config) {
//     var host, i, j, len, len1, port, ref, ref1, servers;
//     if (typeof config === 'string') {
//       [host, port] = config.split(':');
//       config = {
//         host: host,
//         port: port
//       };
//     }
//     if (!config.host || !config.port) {
//       return [];
//     }
//     if (config.host) {
//       if (!Array.isArray(config.host)) {
//         config.host = [config.host];
//       }
//     }
//     if (config.port) {
//       if (!Array.isArray(config.port)) {
//         config.port = [config.port];
//       }
//     }
//     servers = [];
//     ref = config.host || [];
//     for (i = 0, len = ref.length; i < len; i++) {
//       host = ref[i];
//       ref1 = config.port || [];
//       for (j = 0, len1 = ref1.length; j < len1; j++) {
//         port = ref1[j];
//         servers.push({
//           host: host,
//           port: port
//         });
//       }
//     }
//     return servers;
//   };
//   srvs = extract_servers(config);
//   if (config.server) {
//     ref = config.server;
//     for (i = 0, len = ref.length; i < len; i++) {
//       srv = ref[i];
//       srvs.push(...extract_servers(srv));
//     }
//   }
//   config.server = srvs;
//   return config.server = utils.array.flatten(config.server);
// };

// Action
module.exports = {
  handler: async function({config}) {
    var err, error, i, len, ref, server;
    error = null;
    ref = config.server;
    for (i = 0, len = ref.length; i < len; i++) {
      server = ref[i];
      try {
        await this.execute({
          command: `bash -c 'echo > /dev/tcp/${server.host}/${server.port}'`
        });
        if (config.not === true) {
          error = `Address listening: \"${server.host}:${server.port}\"`;
          break;
        }
      } catch (error1) {
        err = error1;
        if (config.not !== true) {
          error = `Address not listening: \"${server.host}:${server.port}\"`;
          break;
        }
      }
    }
    if (error) {
      throw Error(error);
    }
    return true;
  },
  hooks: {
    on_action: require('../wait').hooks.on_action
  },
  metadata: {
    shy: true,
    definitions: definitions
  }
};
