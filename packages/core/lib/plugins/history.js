/*
# Plugin `@nikitajs/core/plugins/history`

The history plugin fill the `children`, `siblings`, and `sibling` properties.
*/

// Plugin
export default {
  name: "@nikitajs/core/plugins/history",
  hooks: {
    "nikita:normalize": function (action) {
      action.children = [];
      if (action.siblings == null) {
        action.siblings = [];
      }
      if (action.parent) {
        action.siblings = action.parent.children;
      }
      if (action.parent) {
        action.sibling = action.siblings.slice(-1)[0];
      }
    },
    "nikita:result": function ({ action, error, output }) {
      if (!action.parent) {
        return;
      }
      // A bastard is not recognized by their parent as children
      // examples include conditions and assertions
      if (action.metadata.bastard) {
        return;
      }
      action.parent.children.push({
        children: action.children,
        metadata: action.metadata,
        config: action.config,
        error: error,
        output: output,
      });
    },
  },
};
