import { clone, merge, mutate, is_object_literal } from "mixme";
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
  "scheduler",
  "ssh",
  "state",
];

export default function ({ action = {}, args }) {
  // Default values
  action.config ??= {};
  action.metadata ??= {};
  let handlerFound = false;
  for (const arg of args) {
    switch (typeof arg) {
      case "function":
        if (handlerFound) {
          throw utils.error("NIKITA_SESSION_INVALID_ARGUMENTS", [
            `handler is already registered, got ${utils.error.got(arg)}`,
          ]);
        }
        handlerFound = true;
        mutate(action, {
          handler: arg,
        });
        break;
      case "string":
        if (handlerFound) {
          throw utils.error("NIKITA_SESSION_INVALID_ARGUMENTS", [
            `handler is already registered, got ${JSON.stringigy(arg)}`,
          ]);
        }
        mutate(action, {
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
          mutate(action, {
            metadata: {
              argument: null,
            },
          });
        } else if (is_object_literal(arg)) {
          const isMagicMode = arg["$"] !== false;
          if (isMagicMode) {
            for (const k in arg) {
              const v = arg[k];
              if (k[0] === "$") {
                if (k === "$$") {
                  mutate(action.metadata, v);
                } else {
                  // Extract the property name from key starting with `$`
                  const prop = k.slice(1);
                  if (properties.includes(prop)) {
                    action[prop] = v;
                  } else {
                    action.metadata[prop] = v;
                  }
                }
              } else {
                if (v !== undefined) {
                  action.config[k] = v;
                }
              }
            }
          } else {
            for (const k in arg) {
              if (k === '$') continue;
              const v = arg[k];
              if (["config", "metadata"].includes(k)) {
                mutate(action[k], v);
              } else {
                action[k] = v;
              }
            }
          }
        } else {
          mutate(action, {
            metadata: {
              argument: arg,
            },
          });
        }
        break;
      default:
        mutate(action, {
          metadata: {
            argument: arg,
          },
        });
    }
  }
  action.config = clone(action.config);
  return action;
}
