
const session = require('../../session');

const handlers = {
  if_exists: async function(action, value) {
    let final_run = true;
    for (const condition of action.conditions.if_exists) {
      try {
        await session({
          $bastard: true,
          $parent: action
        }, async function() {
          return await this.fs.base.stat({
            target: condition
          });
        });
      } catch (error) {
        if (error.code === 'NIKITA_FS_STAT_TARGET_ENOENT') {
          final_run = false;
        } else {
          throw error;
        }
      }
    }
    return final_run;
  },
  unless_exists: async function(action) {
    let final_run = true;
    for (const condition of action.conditions.unless_exists) {
      try {
        await session({
          $bastard: true,
          $parent: action
        }, async function() {
          return await this.fs.base.stat({
            target: condition
          });
        });
        final_run = false;
      } catch (error) {
        if (error.code !== 'NIKITA_FS_STAT_TARGET_ENOENT') {
          throw error;
        }
      }
    }
    return final_run;
  }
};

module.exports = {
  name: '@nikitajs/core/lib/plugins/conditions/exists',
  require: ['@nikitajs/core/lib/plugins/conditions'],
  hooks: {
    'nikita:action': {
      after: '@nikitajs/core/lib/plugins/conditions',
      before: '@nikitajs/core/lib/plugins/metadata/disabled',
      handler: async function(action) {
        let final_run = true;
        for (const condition in action.conditions) {
          if (handlers[condition] == null) {
            continue;
          }
          const local_run = (await handlers[condition].call(null, action));
          if (local_run === false) {
            final_run = false;
          }
        }
        if (!final_run) {
          return action.metadata.disabled = true;
        }
      }
    }
  }
};
