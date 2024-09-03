/*
# @nikitajs/core/plugins/metadata/retry

Reschedule the execution of an action on error.
*/

import { merge } from "mixme";
import utils from "@nikitajs/core/utils";

export default {
  name: "@nikitajs/core/plugins/metadata/retry",
  hooks: {
    "nikita:action": function (action, handler) {
      if (action.metadata.attempt == null) {
        action.metadata.attempt = 0;
      }
      if (action.metadata.retry == null) {
        action.metadata.retry = 1;
      }
      if (action.metadata.sleep == null) {
        action.metadata.sleep = 3000;
      }
      ["attempt", "sleep", "retry"].map((property) => {
        if (typeof action.metadata[property] === "number") {
          if (action.metadata[property] < 0) {
            throw utils.error(
              `METADATA_${property.toUpperCase()}_INVALID_RANGE`,
              [
                `configuration \`${property}\` expect a number above or equal to 0,`,
                `got ${action.metadata[property]}.`,
              ],
            );
          }
        } else if (typeof action.metadata[property] !== "boolean") {
          throw utils.error(
            `METADATA_${property.toUpperCase()}_INVALID_VALUE`,
            [
              `configuration \`${property}\` expect a number or a boolean value,`,
              `got ${JSON.stringify(action.metadata[property])}.`,
            ],
          );
        }
      });
      return function (action) {
        const { retry } = action.metadata;
        const config = merge({}, action.config);
        // Handle error
        const failure = async function (error) {
          if (retry !== true && action.metadata.attempt >= retry - 1) {
            throw error;
          }
          // Sleep
          if (action.metadata.sleep) {
            await new Promise(function (resolve) {
              setTimeout(resolve, action.metadata.sleep);
            });
          }
          // Increment the attempt metadata
          action.metadata.attempt++;
          action.config = merge({}, config);
          // Reschedule
          return run();
        };
        const run = async function () {
          try {
            return await handler.call(null, action);
          } catch (error) {
            return failure(error);
          }
        };
        return run();
      };
    },
  },
};
