// Generated by CoffeeScript 2.5.1
// # `nikita.system.group.read`

// Read and parse the group definition file located in "/etc/group".

// ## Output parameters

// * `groups`   
//   An object where keys are the group names and values are the groups properties.
//   See the parameter `group` for a list of available properties.
// * `group`
//   Properties associated witht the group, only if the input parameter `gid` is
//   provided. Available properties are:   
//   * `group` (string)   
//   Name of the group.
//   * `password` (string)   
//   Group password as a result of the `crypt` function, rarely used.
//   * `gid` (string)   
//   The numerical equivalent of the group name. It is used by the operating
//   system and applications when determining access privileges.
//   * `users` (array[string])   
//   List of users who are members of this group.

// ## Examples

// Retrieve all groups informations:

// ```js
// require('nikita')
// .system.group.read(function(err, {groups}){
//   assert(Array.isArray(groups), true)
// })
// ```

// Retrieve information of an individual group:

// ```js
// require('nikita')
// .system.group.read({
//   gid: 0
// }, function(err, {group}){
//   assert(group.gid, 0)
//   assert(group.group, 'root')
// })
// ```

// ## Schema
var handler, schema, utils;

schema = {
  config: {
    type: 'object',
    properties: {
      'gid': {
        $ref: 'module://@nikitajs/core/lib/actions/fs/chown#/definitions/config/properties/gid',
        description: `Retrieve the information for a specific group name or gid.`
      },
      'target': {
        type: 'string',
        default: '/etc/group',
        description: `Path to the group definition file, default to "/etc/group".`
      }
    }
  }
};

// ## Handler
handler = async function({
    config,
    metadata,
    state,
    tools: {log}
  }) {
  var data, group, groups, stdout, str2groups;
  if (typeof config.gid === 'string' && /\d+/.test(config.gid)) {
    config.gid = parseInt(config.gid, 10);
  }
  // Parse the groups output
  str2groups = function(data) {
    var groups, i, len, line, ref;
    groups = {};
    ref = utils.string.lines(data);
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      line = /(.*)\:(.*)\:(.*)\:(.*)/.exec(line);
      if (!line) {
        continue;
      }
      groups[line[1]] = {
        group: line[1],
        password: line[2],
        gid: parseInt(line[3]),
        users: line[4] ? line[4].split(',') : []
      };
    }
    return groups;
  };
  // Fetch the groups information
  if (!config.target) {
    ({stdout} = (await this.execute({
      command: 'getent group'
    })));
    groups = str2groups(stdout);
  } else {
    ({data} = (await this.fs.base.readFile({
      target: config.target,
      encoding: 'ascii'
    })));
    groups = str2groups(data);
  }
  if (!config.gid) {
    return {
      // Return all the groups
      groups: groups
    };
  }
  // Return a group by name
  if (typeof config.gid === 'string') {
    group = groups[config.gid];
    if (!group) {
      throw Error(`Invalid Option: no gid matching ${JSON.stringify(config.gid)}`);
    }
    return {
      group: group
    };
  } else {
    // Return a group by gid
    group = Object.values(groups).filter(function(group) {
      return group.gid === config.gid;
    })[0];
    if (!group) {
      throw Error(`Invalid Option: no gid matching ${JSON.stringify(config.gid)}`);
    }
    return {
      group: group
    };
  }
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    schema: schema
  }
};

// ## Dependencies
utils = require('../utils');
