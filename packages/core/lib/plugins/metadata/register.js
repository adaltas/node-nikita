// Dependencies
import dedent from "dedent";
import { mutate } from "mixme";

export default {
  name: "@nikitajs/core/plugins/metadata/register",
  hooks: {
    "nikita:schema": {
      before: "@nikitajs/core/plugins/tools/schema",
      handler: function ({ schema }) {
        mutate(schema.definitions.metadata.properties, {
          register: {
            type: "object",
            description: dedent`
          Register one of multiple actions into the current action registry.
        `,
          },
        });
      },
    },
    "nikita:action": async function (action, handler) {
      if (action.metadata.register != null) {
        await action.registry.register(action.metadata.register);
      }
      return handler;
    },
  },
};
