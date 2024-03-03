import { mutate, is_object_literal } from "mixme";
import utils from "@nikitajs/core/utils";

const properties = [
  "context",
  "handler",
  "hooks",
  "metadata",
  "config",
  "parent",
  "plugins",
  "registry",
  "run",
  "scheduler",
  "ssh",
  "state",
];

export default function (args) {
  // Reconstituate the action
  const default_action = () => ({
    config: {},
    metadata: {},
    hooks: {},
    state: {},
  });
  const new_action = default_action();
  for (const arg of args) {
    switch (typeof arg) {
      case "function":
        if (new_action.handler) {
          throw utils.error("NIKITA_SESSION_INVALID_ARGUMENTS", [
            `handler is already registered, got ${utils.error.got(arg)}`,
          ]);
        }
        mutate(new_action, {
          handler: arg,
        });
        break;
      case "string":
        if (new_action.handler) {
          throw utils.error("NIKITA_SESSION_INVALID_ARGUMENTS", [
            `handler is already registered, got ${JSON.stringigy(arg)}`,
          ]);
        }
        mutate(new_action, {
          metadata: {
            argument: arg,
          },
        });
        break;
      case "object":
        if (Array.isArray(arg)) {
          throw utils.error("NIKITA_SESSION_INVALID_ARGUMENTS", [
            `argument cannot be an array, got ${utils.error.got(arg)}`,
          ]);
        }
        if (arg === null) {
          mutate(new_action, {
            metadata: {
              argument: null,
            },
          });
        } else if (is_object_literal(arg)) {
          for (const k in arg) {
            const v = arg[k];
            if (k === "$") {
              // mutate new_action, v
              for (const kk in v) {
                const vv = v[kk];
                if (["config", "metadata"].includes(kk)) {
                  new_action[kk] = { ...new_action[kk], ...vv };
                } else {
                  new_action[kk] = vv;
                }
              }
            } else if (k[0] === "$") {
              if (k === "$$") {
                mutate(new_action.metadata, v);
              } else {
                // Extract the property name from key starting with `$`
                const prop = k.slice(1);
                if (properties.includes(prop)) {
                  new_action[prop] = v;
                } else {
                  new_action.metadata[prop] = v;
                }
              }
            } else {
              if (v !== undefined) {
                new_action.config[k] = v;
              }
            }
          }
        } else {
          mutate(new_action, {
            metadata: {
              argument: arg,
            },
          });
        }
        break;
      default:
        mutate(new_action, {
          metadata: {
            argument: arg,
          },
        });
    }
  }
  // Create empty action when no arguments are provided and not for an empty array
  return new_action;
}
