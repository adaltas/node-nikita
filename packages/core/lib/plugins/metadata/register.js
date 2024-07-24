import utils from "@nikitajs/core/utils";

export default {
  name: "@nikitajs/core/plugins/metadata/register",
  "nikita:schema": function ({ schema }) {
    mutate(schema.definitions.metadata.properties, {
      register: {
        type: "object",
        description: dedent`
          Register one of multiple actions into the current action registry.
        `,
      },
    });
  },
  hooks: {
    "nikita:action": async function (action, handler) {
      if (action.metadata.register != null) {
        await action.registry.register(action.metadata.register)
      }
      return handler;
    },
  },
};
