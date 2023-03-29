// Dependencies
const utils = require('../../../utils');
const definitions = require('./schema.json');

// Errors
const errors = {
  NIKITA_MKDIR_TARGET_RELATIVE: function({config}) {
    return utils.error('NIKITA_MKDIR_TARGET_RELATIVE', ['only absolute path are supported over SSH,', 'target is relative and config `cwd` is not provided,', `got ${JSON.stringify(config.target)}`], {
      target: config.target
    });
  },
  NIKITA_MKDIR_TARGET_INVALID_TYPE: function({stats, target}) {
    return utils.error('NIKITA_MKDIR_TARGET_INVALID_TYPE', ['target exists but it is not a directory,', `got ${JSON.stringify(utils.stats.type(stats.mode))} type`, `for ${JSON.stringify(target)}`], {
      target: target
    });
  }
};

// Action
module.exports = {
  handler: async function ({ config, tools: { log, path }, ssh }) {
    if (!ssh && (config.cwd === true || !config.cwd)) {
      // Configuration validation
      config.cwd = process.cwd();
    }
    if (config.parent === true) {
      config.parent = {};
    }
    config.target = config.cwd
      ? path.resolve(config.cwd, config.target)
      : path.normalize(config.target);
    if (ssh && !path.isAbsolute(config.target)) {
      throw errors.NIKITA_MKDIR_TARGET_RELATIVE({
        config: config,
      });
    }
    // Retrieve every directories including parents
    let parents = config.target.split(path.sep);
    parents.shift(); // first element is empty with absolute path
    if (parents[parents.length - 1] === '') {
      parents.pop();
    }
    parents = Array(parents.length).fill(null).map( (_, i) =>
      '/' + parents.slice(0, parents.length - i).join('/')
    )
    // Discovery of directories to create
    let creates = [];
    let stats
    for(const target of parents) {
      try {
        ({ stats } = await this.fs.base.stat(target));
        if (utils.stats.isDirectory(stats.mode)) {
          break;
        }
        throw errors.NIKITA_MKDIR_TARGET_INVALID_TYPE({
          stats: stats,
          target: target,
        });
      } catch (error) {
        if (error.code === "NIKITA_FS_STAT_TARGET_ENOENT") {
          creates.push(target);
        } else {
          throw error;
        }
      }
    }
    creates = creates.reverse();
    // Target and parent directory creation
    for (let i = 0; i < creates.length; i++) {
      const target = creates[i];
      if (config.exclude != null && config.exclude instanceof RegExp) {
        if (config.exclude.test(path.basename(target))) {
          break;
        }
      }
      const opts = {};
      const attributes = ['mode', 'uid', 'gid', 'size', 'atime', 'mtime'];
      for (const attr of attributes) {
        const val =
          i === creates.length - 1 ? config[attr] : config.parent?.[attr];
        if (val != null) {
          opts[attr] = val;
        }
      }
      await this.fs.base.mkdir(target, opts);
      log({
        message: `Directory "${target}" created `,
        level: "INFO",
      });
    }
    // Target directory update
    // Do not create directory unless `force` is set
    if (config.force && creates.length === 0) {
      log({
        message: "Directory already exists",
        level: "DEBUG",
      });
      await this.fs.chown({
        $if: config.uid != null || config.gid != null,
        target: config.target,
        stats: stats,
        uid: config.uid,
        gid: config.gid,
      });
      await this.fs.chmod({
        $if: config.mode != null,
        target: config.target,
        stats: stats,
        mode: config.mode,
      });
    }
    return {};
  },
  hooks: {
    on_action: function ({ config, metadata }) {
      if (config.parent == null) {
        config.parent = {};
      }
      if (config.parent === true) {
        return (config.parent = {});
      }
    },
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
