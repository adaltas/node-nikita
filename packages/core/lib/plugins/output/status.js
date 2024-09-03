import { is_object, is_object_literal } from "mixme";
import utils from "@nikitajs/core/utils";

export default {
  name: "@nikitajs/core/plugins/output/status",
  require: ["@nikitajs/core/plugins/history"],
  recommand: [
    // Status is set to `false` when action is disabled
    "@nikitajs/core/plugins/metadata/disabled",
    // Honors raw_output if present
    "@nikitajs/core/plugins/metadata/raw",
  ],
  hooks: {
    "nikita:normalize": function (action) {
      action.tools ??= {};
      action.tools.status = function (index) {
        if (arguments.length === 0) {
          return action.children.some(
            (sibling) =>
              !sibling.metadata.shy && sibling.output?.$status === true,
          );
        } else {
          const l = action.children.length;
          const i = index < 0 ? l + index : index;
          const sibling = action.children[i];
          if (!sibling) {
            throw Error(`Invalid Index ${index}`);
          }
          return sibling.output.$status;
        }
      };
    },
    "nikita:result": {
      before: "@nikitajs/core/plugins/history",
      handler: function ({ action, error, output }) {
        // Honors the disabled plugin, status is `false`
        // when the action is disabled
        if (action.metadata.disabled) {
          arguments[0].output = {
            $status: false,
          };
          return;
        }
        const inherit = function (output) {
          if (output == null) {
            output = {};
          }
          output.$status = action.children.some(function (child) {
            if (child.metadata.shy) {
              return false;
            }
            return child.output?.$status === true;
          });
          return output;
        };
        if (!error && !action.metadata.raw_output) {
          return (arguments[0].output = (function () {
            if (typeof output === "boolean") {
              return {
                $status: output,
              };
            } else if (is_object_literal(output)) {
              if (Object.prototype.hasOwnProperty.call(output, "$status")) {
                output.$status = !!output.$status;
                return output;
              } else {
                return inherit(output);
              }
            } else if (output === null) {
              return output;
            } else if (output == null) {
              return inherit(output);
            } else if (is_object(output)) {
              return output;
            } else if (
              Array.isArray(output) ||
              typeof output === "string" ||
              typeof output === "number"
            ) {
              return output;
            } else {
              throw utils.error("HANDLER_INVALID_OUTPUT", [
                "expect a boolean or an object or nothing",
                "unless the `raw_output` configuration is activated,",
                `got ${JSON.stringify(output)}`,
              ]);
            }
          })());
        }
      },
    },
  },
};
