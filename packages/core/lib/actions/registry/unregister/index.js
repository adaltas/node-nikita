// Action
export default {
  handler: function ({ config, parent }) {
    parent.registry.unregister(config.namespace);
  },
  metadata: {
    raw_output: true,
  },
};
