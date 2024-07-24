// Action
export default {
  handler: async function({config, parent}) {
    if(config.actions){
      await parent.registry.register(config.actions);
    }
    if(config.namespace) {
      await parent.registry.register(config.namespace, config.action);
    }
  },
  metadata: {
    raw_output: true
  },
};
