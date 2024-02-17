/*
The `args` plugin place the original argument into the action "args" property.
*/

// Plugin
export default {
  name: "@nikitajs/core/plugins/args",
  hooks: {
    "nikita:arguments": {
      handler: function ({ args, child }, handler) {
        // return handler is args.length is 0 # nikita is called without any args, eg `nikita.call(...)`
        // Erase all arguments to re-inject them later
        // return null if args.length is 1 and args[0]?.args
        if (child?.metadata?.raw_input) {
          arguments[0].args = [{}];
        }
        return function () {
          const action = handler.apply(null, arguments);
          // If raw_input is activated, just pass arguments as is
          // Always one action since arguments are erased
          if (child?.metadata?.raw_input) {
            action.metadata.raw_input = true;
          }
          action.args = args;
          return action;
        };
      },
    },
    "nikita:normalize": function (action, handler) {
      return async function () {
        // Prevent arguments to move into config by normalize
        const args = action.args;
        delete action.args;
        action = await handler.apply(null, arguments);
        action.args = args;
        return action;
      };
    },
  },
};
