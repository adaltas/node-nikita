// Action
export default {
  handler: function({parent, args: [namespace]}) {
    parent.registry.unregister(namespace);
  },
  metadata: {
    raw: true
  },
};
