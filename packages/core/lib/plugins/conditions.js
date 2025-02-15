import session from "@nikitajs/core/session";

const handlers = {
  if: async function (action) {
    for (let condition of action.conditions.if) {
      if (typeof condition === "function") {
        condition = await session({
          $bastard: true,
          $handler: condition,
          $parent: action,
          $raw_output: true,
          ...action.config,
        });
      }
      const run = (function () {
        switch (typeof condition) {
          case "undefined":
            return false;
          case "boolean":
            return condition;
          case "number":
            return !!condition;
          case "string":
            return !!condition.length;
          case "object":
            if (Buffer.isBuffer(condition)) {
              return !!condition.length;
            } else if (condition === null) {
              return false;
            } else {
              return !!Object.keys(condition).length;
            }
          default:
            throw Error("Value type is not handled");
        }
      })();
      if (run === false) {
        return false;
      }
    }
    return true;
  },
  unless: async function (action) {
    for (let condition of action.conditions.unless) {
      if (typeof condition === "function") {
        condition = await session({
          $bastard: true,
          $handler: condition,
          $parent: action,
          $raw_output: true,
          ...action.config,
        });
      }
      const run = (function () {
        switch (typeof condition) {
          case "undefined":
            return true;
          case "boolean":
            return !condition;
          case "number":
            return !condition;
          case "string":
            return !condition.length;
          case "object":
            if (Buffer.isBuffer(condition)) {
              return !condition.length;
            } else if (condition === null) {
              return true;
            } else {
              return !Object.keys(condition).length;
            }
          default:
            throw Error("Value type is not handled");
        }
      })();
      if (run === false) {
        return false;
      }
    }
    return true;
  },
};

export default {
  name: "@nikitajs/core/plugins/conditions",
  require: [
    "@nikitajs/core/plugins/metadata/raw",
    "@nikitajs/core/plugins/metadata/disabled",
  ],
  hooks: {
    "nikita:normalize": {
      handler: function (action, handler) {
        // Ventilate conditions properties defined at root
        const conditions = {};
        for (const property in action.metadata) {
          let value = action.metadata[property];
          if (/^(if|unless)($|_[\w_]+$)/.test(property)) {
            if (conditions[property]) {
              throw Error("CONDITIONS_DUPLICATED_DECLARATION", [
                `Property ${property} is defined multiple times,`,
                "at the root of the action and inside conditions",
              ]);
            }
            if (!Array.isArray(value)) {
              value = [value];
            }
            conditions[property] = value;
            delete action.metadata[property];
          }
        }
        return async function () {
          action = await handler.call(null, ...arguments);
          action.conditions = conditions;
          return action;
        };
      },
    },
    "nikita:action": {
      before: "@nikitajs/core/plugins/metadata/disabled",
      after: "@nikitajs/core/plugins/templated",
      handler: async function (action) {
        for (const condition in action.conditions) {
          if (handlers[condition] == null) {
            continue;
          }
          if ((await handlers[condition].call(null, action)) === false) {
            action.metadata.disabled = true;
            break;
          }
        }
      },
    },
  },
};
