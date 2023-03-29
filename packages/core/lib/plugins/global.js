
/*
The `global` plugin look it the parent tree for a "global" configuration. If
found, it will merge its value with the current configuration.

The functionnality is used to provide global default settings to a group of
actions. Consider for example the Docker actions. Each action has specific
configuration properties but there are also some properties which benefits
from being shared by all the Docker actions such as the adress of the Docker
daemon if it is not run locally.
*/

// Plugin
module.exports = {
  name: '@nikitajs/core/lib/plugins/global',
  require: [
    '@nikitajs/core/lib/plugins/tools/find'
  ],
  hooks: {
    'nikita:action': {
      handler: async function(action) {
        const global = action.metadata.global;
        if (!global) {
          return action;
        }
        action.config[global] = (await action.tools.find(function({config}) {
          return config[global];
        }));
        for (const k in action.config[global]) {
          const v = action.config[global][k];
          if (action.config[k] == null) {
            action.config[k] = v;
          }
        }
        delete action.config[global];
        return action;
      }
    }
  }
};
