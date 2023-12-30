
import session from '@nikitajs/core/session';
import utils from '@nikitajs/core/utils';

const handlers = {
  if_os: async function(action) {
    return await session({
      $bastard: true,
      $parent: action
    }, async function() {
      const { $status, stdout } = await this.execute(utils.os.command).catch(
        (error) => {
          if (error.exit_code === 2) {
            throw utils.error("NIKITA_PLUGIN_OS_UNSUPPORTED_DISTRIB", [
              "your current distribution is not yet listed,",
              "please report to us,",
              `it name is ${JSON.stringify(error.stdout)}`,
            ]);
          }
          throw error;
        }
      );
      if (!$status) {
        return false;
      }
      let [arch, distribution, version, linux_version] = stdout.split('|');
      let match;
      if (match = /^(\d+)\.(\d+)\.(\d+)/.exec(version)) {
        // Note, CentOS 7 version currently return version "7.9.2009", transforming it to "5.19"
        // means that the check runs agains "5.19.0" later on and may fail
        // Remove patch version (eg. 7.8.12 -> 7.8)
        // Instead, remove any information after the patch value
        version = `${match[0]}`;
      }
      if (match = /^(\d+)\.(\d+)\.(\d+)/.exec(linux_version)) {
        // Note, arch linux currently return the linux version "5.15.49", transforming it to "5.19"
        // means that the check runs agains "5.19.0" later on and may fail
        // linux_version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec linux_version
        // Instead, remove any information after the patch value
        linux_version = `${match[0]}`;
      }
      match = action.conditions.if_os.some(function(condition) {
        const a = !condition.arch.length || condition.arch.some(function(value) {
          if (typeof value === 'string' && value === arch) {
            // Uses `uname -m` internally.
            // Node.js values: 'arm', 'arm64', 'ia32', 'mips', 'mipsel', 'ppc', 'ppc64', 's390', 's390x', 'x32', and 'x64'
            // `uname` values: see https://en.wikipedia.org/wiki/Uname#Examples
            return true;
          }
          if (value instanceof RegExp && value.test(arch)) {
            return true;
          }
        });
        const n = !condition.distribution.length || condition.distribution.some(function(value) {
          if (typeof value === 'string' && value === distribution) {
            return true;
          }
          if (value instanceof RegExp && value.test(distribution)) {
            return true;
          }
        });
        // Arch Linux has only linux_version
        const v = !version.length || !condition.version.length || condition.version.some(function(value) {
          version = utils.semver.sanitize(version, '0');
          if (typeof value === 'string' && utils.semver.satisfies(version, value)) {
            return true;
          }
          if (value instanceof RegExp && value.test(version)) {
            return true;
          }
        });
        const lv = !condition.linux_version.length || condition.linux_version.some(function(value) {
          linux_version = utils.semver.sanitize(linux_version, '0');
          if (typeof value === 'string' && utils.semver.satisfies(linux_version, value)) {
            return true;
          }
          if (value instanceof RegExp && value.test(linux_version)) {
            return true;
          }
        });
        return a && n && v && lv;
      });
      if (!match) {
        return false;
      }
    }).then( ({$status}) => $status);
  },
  unless_os: async function(action) {
    return await session({
      $bastard: true,
      $parent: action
    }, async function() {
      const { $status, stdout } = await this.execute(utils.os.command).catch(
        (error) => {
          if (error.exit_code === 2) {
            throw utils.error("NIKITA_PLUGIN_OS_UNSUPPORTED_DISTRIB", [
              "your current distribution is not yet listed,",
              "please report to us,",
              `it name is ${JSON.stringify(error.stdout)}`,
            ]);
          }
          throw error;
        }
      );
      if (!$status) {
        return false;
      }
      let match;
      let [arch, distribution, version, linux_version] = stdout.split('|');
      if (match = /^(\d+)\.(\d+)\.(\d+)/.exec(version)) {
        // Note, CentOS 7 version currently return version "7.9.2009", transforming it to "5.19"
        // means that the check runs agains "5.19.0" later on and may fail
        // Remove patch version (eg. 7.8.12 -> 7.8)
        // Instead, remove any information after the patch value
        version = `${match[0]}`;
      }
      // Note, arch linux currently return the linux version "5.15.49", transforming it to "5.19"
      // means that the check runs agains "5.19.0" later on and may fail
      // linux_version = "#{match[0]}" if match = /^(\d+)\.(\d+)/.exec linux_version
      // Instead, remove any information after the patch value
      match = action.conditions.unless_os.some(function(condition) {
        const a = !condition.arch.length || condition.arch.some(function(value) {
          if (typeof value === 'string' && value === arch) {
            return true;
          }
          if (value instanceof RegExp && value.test(arch)) {
            return true;
          }
        });
        const n = !condition.distribution.length || condition.distribution.some(function(value) {
          if (typeof value === 'string' && value === distribution) {
            return true;
          }
          if (value instanceof RegExp && value.test(distribution)) {
            return true;
          }
        });
        // Arch Linux has only linux_version
        const v = !version.length || !condition.version.length || condition.version.some(function(value) {
          version = utils.semver.sanitize(version, '0');
          if (typeof value === 'string' && utils.semver.satisfies(version, value)) {
            return true;
          }
          if (value instanceof RegExp && value.test(version)) {
            return true;
          }
        });
        const lv = !condition.linux_version.length || condition.linux_version.some(function(value) {
          linux_version = utils.semver.sanitize(linux_version, '0');
          if (typeof value === 'string' && utils.semver.satisfies(linux_version, value)) {
            return true;
          }
          if (value instanceof RegExp && value.test(linux_version)) {
            return true;
          }
        });
        return a && n && v && lv;
      });
      if (match) {
        return false;
      }
    }).then( ({$status}) => $status);
  }
};

export default {
  name: '@nikitajs/core/plugins/conditions/os',
  require: ['@nikitajs/core/plugins/conditions'],
  hooks: {
    'nikita:normalize': {
      after: '@nikitajs/core/plugins/conditions',
      handler: function(action, handler) {
        return async function() {
          action = await handler.call(null, action);
          if (!action.conditions) {
            return;
          }
          // Normalize conditions
          for (const config of [action.conditions.if_os, action.conditions.unless_os]) {
            if (!config) {
              continue;
            }
            for (const condition of config) {
              if (condition.arch == null) {
                condition.arch = [];
              }
              if (!Array.isArray(condition.arch)) {
                condition.arch = [condition.arch];
              }
              if (condition.distribution == null) {
                condition.distribution = [];
              }
              if (!Array.isArray(condition.distribution)) {
                condition.distribution = [condition.distribution];
              }
              if (condition.version == null) {
                condition.version = [];
              }
              if (!Array.isArray(condition.version)) {
                condition.version = [condition.version];
              }
              condition.version = utils.semver.sanitize(condition.version, 'x');
              if (condition.linux_version == null) {
                condition.linux_version = [];
              }
              if (!Array.isArray(condition.linux_version)) {
                condition.linux_version = [condition.linux_version];
              }
              condition.linux_version = utils.semver.sanitize(condition.linux_version, 'x');
            }
          }
          return action;
        };
      }
    },
    'nikita:action': {
      after: '@nikitajs/core/plugins/conditions',
      before: '@nikitajs/core/plugins/metadata/disabled',
      handler: async function(action) {
        for (const condition in action.conditions) {
          if (handlers[condition] == null) {
            continue;
          }
          if (await handlers[condition].call(null, action) === false) {
            action.metadata.disabled = true;
          }
        }
      }
    }
  }
};
