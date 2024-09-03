import session from "@nikitajs/core/session";
import { is_object_literal } from "mixme";

const handlers = {
  if_execute: async function (action) {
    for (const condition of action.conditions.if_execute) {
      try {
        const { $status } = await session(
          {
            $bastard: true,
            $namespace: ["execute"],
            $parent: action,
            ...(is_object_literal(condition) ? condition : {}),
          },
          is_object_literal(condition) ? null : condition,
        );
        if (!$status) {
          return false;
        }
      } catch (error) {
        const { code } = await session(
          {
            $bastard: true,
            $namespace: ["execute"],
            $parent: action,
            ...(is_object_literal(condition) ? condition : {}),
          },
          is_object_literal(condition) ? null : condition,
          function ({ config }) {
            return {
              code: config.code,
            };
          },
        );
        if (code.false.length && !code.false.includes(error.exit_code)) {
          // If `code.false` is present,
          // use it instead of error to disabled the action
          throw error;
        }
        return false;
      }
    }
    return true;
  },
  unless_execute: async function (action) {
    for (const condition of action.conditions.unless_execute) {
      try {
        const { $status } = await session(
          {
            $bastard: true,
            $namespace: ["execute"],
            $parent: action,
            ...(is_object_literal(condition) ? condition : {}),
          },
          is_object_literal(condition) ? null : condition,
        );
        if ($status) {
          return false;
        }
      } catch (error) {
        const { code } = await session(
          {
            $bastard: true,
            $namespace: ["execute"],
            $parent: action,
            ...(is_object_literal(condition) ? condition : {}),
          },
          is_object_literal(condition) ? null : condition,
          function ({ config }) {
            return {
              code: config.code,
            };
          },
        );
        if (code.false.length && !code.false.includes(error.exit_code)) {
          // If `code.false` is present,
          // use it instead of error to to disabled the action
          throw error;
        }
      }
    }
    return true;
  },
};

export default {
  name: "@nikitajs/core/plugins/conditions/execute",
  require: ["@nikitajs/core/plugins/conditions"],
  hooks: {
    "nikita:action": {
      after: "@nikitajs/core/plugins/conditions",
      before: "@nikitajs/core/plugins/metadata/disabled",
      handler: async function (action) {
        for (const condition in action.conditions) {
          if (handlers[condition] == null) {
            continue;
          }
          if ((await handlers[condition].call(null, action)) === false) {
            action.metadata.disabled = true;
          }
        }
      },
    },
  },
};
