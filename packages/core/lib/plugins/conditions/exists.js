
import session from '@nikitajs/core/session';

const handlers = {
  if_exists: async function(action, value) {
    for (const condition of action.conditions.if_exists) {
      try {
        await session({
          $bastard: true,
          $parent: action
        }, async function() {
          return await this.fs.stat({
            target: condition
          });
        });
      } catch (error) {
        if (error.code === 'NIKITA_FS_STAT_TARGET_ENOENT') {
          return false;
        } else {
          throw error;
        }
      }
    }
    return true;
  },
  unless_exists: async function(action) {
    for (const condition of action.conditions.unless_exists) {
      try {
        await session({
          $bastard: true,
          $parent: action
        }, async function() {
          return await this.fs.stat({
            target: condition
          });
        });
        return false;
      } catch (error) {
        if (error.code !== 'NIKITA_FS_STAT_TARGET_ENOENT') {
          throw error;
        }
      }
    }
    return true;
  }
};

export default {
  name: '@nikitajs/core/plugins/conditions/exists',
  require: ['@nikitajs/core/plugins/conditions'],
  hooks: {
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
