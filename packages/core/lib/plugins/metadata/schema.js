/*
# Plugin `@nikitajs/core/plugins/metadata/schema`

The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
*/

// Dependencies
import dedent from "dedent";
import { mutate } from "mixme";

// Plugin
export default {
  name: "@nikitajs/core/plugins/metadata/schema",
  require: ["@nikitajs/core/plugins/tools/schema"],
  hooks: {
    "nikita:schema": {
      before: "@nikitajs/core/plugins/tools/schema",
      handler: function ({ schema }) {
        mutate(schema.definitions.metadata.properties, {
          definitions: {
            type: "object",
            description: dedent`
            Schema definition or \`false\` to disable schema validation in the
            current action.
          `,
          },
        });
      },
    },
    "nikita:action": {
      after: [
        "@nikitajs/core/plugins/global",
        "@nikitajs/core/plugins/metadata/disabled",
      ],
      handler: async function (action) {
        if (action.metadata.schema === false) {
          return;
        }
        const error = await action.tools.schema.validate(action);
        if (error) {
          throw error;
        }
      },
    },
  },
};
