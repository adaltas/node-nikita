// Action
export default {
  handler: function ({ parent, args: [namespace] }) {
    return parent.registry.get(namespace);
  },
  metadata: {
    raw: true,
  },
};
