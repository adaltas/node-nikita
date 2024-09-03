/*
# Plugin `@nikitajs/core/plugins/metadata/raw`

Affect the normalization of input and output properties.
*/

// Dependencies
import dedent from "dedent";
import { mutate } from "mixme";

// Plugin
export default {
  name: "@nikitajs/core/plugins/metadata/raw",
  hooks: {
    "nikita:schema": {
      before: "@nikitajs/core/plugins/tools/schema",
      handler: function ({ schema }) {
        mutate(schema.definitions.metadata.properties, {
          raw_output: {
            type: "boolean",
            description: dedent`
            Indicates the position of the action relative to its parent and
            sibling action. It is unique to each action.
          `,
            readOnly: true,
          },
        });
      },
    },
  },
};
