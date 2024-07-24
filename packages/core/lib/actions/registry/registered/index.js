// Action
export default {
  handler: function({config, parent}) {
    return parent.registry.registered(config.namespace);
  },
  metadata: {
    raw_output: true
  },
};
