// Action
export default {
  handler: async function({parent, args: [namespace, action]}) {
    await parent.registry.register(namespace, action);
  },
  metadata: {
    raw: true
  },
};
