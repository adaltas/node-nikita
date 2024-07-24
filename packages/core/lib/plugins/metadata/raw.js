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
    "nikita:schema": function ({ schema }) {
      mutate(schema.definitions.metadata.properties, {
        raw: {
          type: "boolean",
          description: dedent`
            Indicates the level number of the action in the Nikita session
            tree.
          `,
          readOnly: true,
        },
        raw_input: {
          type: "boolean",
          description: dedent`
            Indicates the index of an action relative to its sibling actions in
            the Nikita session tree.
          `,
          readOnly: true,
        },
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
    "nikita:registry:normalize": {
      handler: function (action) {
        action.metadata ??= {};
        if (typeof action.metadata.raw === "boolean") {
          action.metadata.raw_input ??= action.metadata.raw;
          action.metadata.raw_output ??= action.metadata.raw;
        }
      },
    },
    "nikita:action": {
      handler: function (action) {
        if (typeof action.metadata.raw === "boolean") {
          action.metadata.raw_input ??= action.metadata.raw;
          action.metadata.raw_output ??= action.metadata.raw;
        }
      },
    },
  },
};
