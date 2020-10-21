// Generated by CoffeeScript 2.5.1
// `nikita.file.types.ceph_conf`

// Ceph is posix-compliant distributed file system. Writes [configuration
// file][ceph-conf] as Ceph daemons expect it.

// ## Schema
var handler, path, schema, utils;

schema = {
  type: 'object',
  properties: {
    'rootdir': {
      type: 'string',
      description: `Path to the mount point corresponding to the root directory, optional.`
    },
    'backup': {
      type: ['boolean', 'string'],
      description: `Create a backup, append a provided string to the filename extension or
a timestamp if value is not a string, only apply if the target file
exists and is modified.`
    },
    'clean': {
      type: 'boolean',
      description: `Remove all the lines whithout a key and a value, default to "true".`
    },
    'content': {
      type: ['object', 'string'],
      description: `Object to stringify.`
    },
    'merge': {
      type: 'boolean',
      description: `Read the target if it exists and merge its content.`
    },
    'separator': {
      type: 'string',
      description: `Default separator between keys and values, default to " : ".`
    },
    'target': {
      type: 'string',
      description: `File to write.`
    }
  },
  required: ['target']
};

// ## Handler
handler = function({config}) {
  if (config.rootdir) {
    // log message: "Entering file.types.ceph_conf", level: 'DEBUG', module: 'nikita/lib/file/types/ceph_conf'
    config.target = `${path.join(config.rootdir, config.target)}`;
  }
  return this.file.ini({
    stringify: utils.ini.stringify,
    parse: utils.ini.parse_multi_brackets,
    escape: false
  }, config);
};

// ## Exports
module.exports = {
  handler: handler,
  schema: schema
};

// ## Dependencies
path = require('path');

utils = require('../utils');

// [ceph-conf]:(http://docs.ceph.com/docs/jewel/rados/configuration/ceph-conf/)
