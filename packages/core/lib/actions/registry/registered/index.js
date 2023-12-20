// Action
export default {
  handler: function({parent, args: [namespace]}) {
    return parent.registry.registered(namespace);
  },
  metadata: {
    raw: true
  },
};
