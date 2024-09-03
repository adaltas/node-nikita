/*
# Plugin `@nikitajs/core/plugins/assertions/exists`

Assert that a file exist.

The plugin register two action properties, `$assert_exists` and `$unassert_exists`.
*/

import session from "@nikitajs/core/session";
import utils from "@nikitajs/core/utils";
import { mutate } from "mixme";

const handlers = {
  assert_exists: async function (action) {
    let final_run = true;
    for (const assertion of action.assertions.assert_exists) {
      const run = await session(
        {
          $bastard: true,
          $parent: action,
          $raw_output: true,
        },
        async function () {
          const { exists } = await this.fs.exists({
            target: assertion,
          });
          return exists;
        },
      );
      if (run === false) {
        final_run = false;
      }
    }
    return final_run;
  },
  unassert_exists: async function (action) {
    let final_run = true;
    for (const assertion of action.assertions.unassert_exists) {
      const run = await session(
        {
          $bastard: true,
          $parent: action,
          $raw_output: true,
        },
        async function () {
          const { exists } = await this.fs.exists({
            target: assertion,
          });
          return exists;
        },
      );
      if (run === true) {
        final_run = false;
      }
    }
    return final_run;
  },
};

export default {
  name: "@nikitajs/core/plugins/assertions/exists",
  require: [
    "@nikitajs/core/plugins/metadata/raw",
    "@nikitajs/core/plugins/metadata/disabled",
  ],
  hooks: {
    "nikita:normalize": {
      // This is hanging, no time for investigation
      // after: [
      //   '@nikitajs/core/plugins/assertions'
      // ]
      handler: function (action, handler) {
        // Ventilate assertions properties defined at root
        const assertions = {};
        for (const property in action.metadata) {
          let value = action.metadata[property];
          if (/^(un)?assert_exists$/.test(property)) {
            if (assertions[property]) {
              throw Error("ASSERTION_DUPLICATED_DECLARATION", [
                `Property ${property} is defined multiple times,`,
                "at the root of the action and inside assertions",
              ]);
            }
            if (!Array.isArray(value)) {
              value = [value];
            }
            assertions[property] = value;
            delete action.metadata[property];
          }
        }
        return async function () {
          action = await handler.call(null, ...arguments);
          mutate(action.assertions, assertions);
          return action;
        };
      },
    },
    "nikita:result": async function ({ action }) {
      let final_run = true;
      for (const assertion in action.assertions) {
        if (handlers[assertion] == null) {
          continue;
        }
        const local_run = await handlers[assertion].call(null, action);
        if (local_run === false) {
          final_run = false;
        }
      }
      if (!final_run) {
        throw utils.error("NIKITA_INVALID_ASSERTION", [
          "action did not validate the assertion",
        ]);
      }
    },
  },
};
