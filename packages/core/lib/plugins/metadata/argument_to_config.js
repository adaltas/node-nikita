/*
# Plugin `@nikitajs/core/plugins/metadata/argument_to_config`

The `argument` plugin map an argument which is not an object into a configuration property.
*/

// Dependencies
import { mutate } from "mixme";

// Plugin
export default {
  name: "@nikitajs/core/plugins/metadata/argument_to_config",
  hooks: {
    "nikita:schema": {
      before: "@nikitajs/core/plugins/tools/schema",
      handler: function ({ schema }) {
        mutate(schema.definitions.metadata.properties, {
          argument_to_config: {
            type: "string",
            description: `Maps the argument passed to the action to a configuration property.`,
          },
        });
      },
    },
    "nikita:action": {
      before: "@nikitajs/core/plugins/metadata/schema",
      handler: function (action) {
        if (
          action.metadata.argument_to_config &&
          action.config[action.metadata.argument_to_config] === undefined
        ) {
          action.config[action.metadata.argument_to_config] =
            action.metadata.argument;
        }
      },
    },
  },
};
