
/*
Plugin `@nikitajs/core/lib/plugins/pubsub`

Provide a mechanism for actions to wait for a key to be published before
continuing their execution.

*/
module.exports = {
  name: '@nikitajs/core/lib/plugins/pubsub',
  require: '@nikitajs/core/lib/plugins/tools/find',
  hooks: {
    'nikita:action': async function(action) {
      const engine = await action.tools.find(
        ({metadata}) => metadata.pubsub
      );
      if (!engine) {
        return action;
      }
      action.tools.pubsub = {
        get: function(key) {
          return engine.get(key);
        },
        set: function(key, value) {
          return engine.set(key, value);
        }
      };
    }
  }
};
