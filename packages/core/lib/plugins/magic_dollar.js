/*
# Plugin `@nikitajs/core/plugins/magic_dollar`

The `magic_dollar` plugin extract all variables starting with a dollar sign.
*/

// Plugin
export default {
  name: "@nikitajs/core/plugins/magic_dollar",
  hooks: {
    "nikita:normalize": {
      handler: function (action) {
        const results = [];
        for (const k in action) {
          const v = action[k];
          if (k[0] !== "$") {
            continue;
          }
          const prop = k.substr(1);
          switch (prop) {
            case "handler":
              action.handler = v;
              break;
            case "parent":
              action.parent = v;
              break;
            case "scheduler":
              action.scheduler = v;
              break;
            default:
              action.metadata[prop] = v;
          }
          results.push(delete action[k]);
        }
        return results;
      },
    },
  },
};
