/*
The `args` plugin place the original argument into the action "args" property.
*/

// Plugin
export default {
  name: "@nikitajs/core/plugins/args",
  hooks: {
    "nikita:arguments": {
      handler: function ({ args, action }, handler) {
        // return handler is args.length is 0 # nikita is called without any args, eg `nikita.call(...)`
        // Erase all arguments to re-inject them later
        // return null if args.length is 1 and args[0]?.args
        const rawInput = action?.metadata?.raw_input
        if (rawInput === true) {
          arguments[0].args = [{}];
        }
        return function () {
          const action = handler.apply(null, arguments);
          // If raw_input is activated, just pass arguments as is
          // Always one action since arguments are erased
          if (rawInput === true) {
            action.metadata.raw_input = true;
          }
          action.args = args;
          return action;
        };
      },
    },
  },
};
