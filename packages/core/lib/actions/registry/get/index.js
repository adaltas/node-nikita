// Action
export default {
  handler: function ({ config, parent }) {
    return parent.registry.get(config.namespace);
  },
  metadata: {
    raw_output: true,
  },
};
