
import session from '@nikitajs/core/session';

const handlers = {
  if_execute: async function(action) {
    let final_run = true;
    for (const condition of action.conditions.if_execute) {
      try {
        const {$status} = await session({
          $bastard: true,
          $namespace: ['execute'],
          $parent: action
        }, condition);
        if (!$status) {
          final_run = false;
        }
      } catch (error) {
        const {code} = await session({
          $bastard: true,
          $namespace: ['execute'],
          $parent: action
        }, condition, function({config}) {
          return {
            code: config.code
          };
        });
        if (code.false.length && !code.false.includes(error.exit_code)) {
          // If `code.false` is present,
          // use it instead of error to disabled the action
          throw error;
        }
        final_run = false;
      }
    }
    return final_run;
  },
  unless_execute: async function(action) {
    let final_run = true;
    for (const condition of action.conditions.unless_execute) {
      try {
        const {$status} = await session({
          $bastard: true,
          $namespace: ['execute'],
          $parent: action
        }, condition);
        if ($status) {
          final_run = false;
        }
      } catch (error) {
        const {code} = await session({
          $bastard: true,
          $namespace: ['execute'],
          $parent: action
        }, condition, function({config}) {
          return {
            code: config.code
          };
        });
        if (code.false.length && !code.false.includes(error.exit_code)) {
          // If `code.false` is present,
          // use it instead of error to to disabled the action
          throw error;
        }
      }
    }
    return final_run;
  }
};

export default {
  name: '@nikitajs/core/plugins/conditions/execute',
  require: ['@nikitajs/core/plugins/conditions'],
  hooks: {
    'nikita:action': {
      after: '@nikitajs/core/plugins/conditions',
      before: '@nikitajs/core/plugins/metadata/disabled',
      handler: async function(action) {
        let final_run = true;
        for (const condition in action.conditions) {
          if (handlers[condition] == null) {
            continue;
          }
          const local_run = await handlers[condition].call(null, action);
          if (local_run === false) {
            final_run = false;
          }
        }
        if (!final_run) {
          action.metadata.disabled = true;
        }
      }
    }
  }
};
