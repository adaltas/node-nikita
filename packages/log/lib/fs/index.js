// Dependencies
const fs = require('fs');
const path = require('path');
const definitions = require('./schema.json');

// ## Exports
module.exports = {
  handler: async function({config}) {
    // Normalization
    let logdir = path.dirname(config.filename);
    if (config.basedir) {
      logdir = path.resolve(config.basedir, logdir);
    }
    // Archive config
    let latestdir;
    if (config.archive) {
      latestdir = path.resolve(logdir, 'latest');
      const now = new Date();
      if (config.archive === true) {
        config.archive = `${now.getFullYear()}`.slice(-2) + `0${now.getFullYear()}`.slice(-2) + `0${now.getDate()}`.slice(-2);
      }
      logdir = path.resolve(config.basedir, config.archive);
    }
    try {
      await this.fs.base.mkdir(logdir, {
        ssh: false
      });
    } catch (error) {
      if (error.code !== 'NIKITA_FS_MKDIR_TARGET_EEXIST') {
        throw error;
      }
    }
    // Events
    if (config.stream == null) {
      config.stream = fs.createWriteStream(path.resolve(logdir, path.basename(config.filename)));
    }
    await this.log.stream(config);
    // Handle link to latest directory
    return (await this.fs.base.symlink({
      $if: latestdir,
      source: logdir,
      target: latestdir
    }));
  },
  hooks: {
    on_action: {
      before: ['@nikitajs/core/lib/plugins/metadata/schema'],
      after: ['@nikitajs/core/lib/plugins/ssh'],
      handler: function({config, ssh}) {
        var ref;
        // With ssh, filename contain the host or ip address
        if (config.filename == null) {
          config.filename = `${ssh?.config?.host || 'local'}.log`;
        }
        // Log is always local
        return config.ssh = false;
      }
    }
  },
  metadata: {
    definitions: definitions
  }
};
