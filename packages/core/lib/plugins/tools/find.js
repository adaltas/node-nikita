/*
# Plugin `@nikitajs/core/plugins/tools/find`

Traverse the parent hierarchy until it find a value. The traversal will only
stop if the user function return anything else than `undefined`, including
`null` or `false`.
*/

import utils from "@nikitajs/core/utils";

const find = async function (action, finder) {
  const precious = await finder(action, finder);
  if (precious !== undefined) {
    return precious;
  }
  if (!action.parent) {
    return undefined;
  }
  return find(action.parent, finder);
};

const validate = function (action, args) {
  let finder;
  if (args.length === 1) {
    [finder] = args;
  } else if (args.length === 2) {
    [action, finder] = args;
  } else {
    if (!action) {
      throw utils.error("TOOLS_FIND_INVALID_ARGUMENT", [
        "action signature is expected to be",
        "`finder` or `action, finder`",
        `got ${JSON.stringify(args)}`,
      ]);
    }
  }
  if (!action) {
    throw utils.error("TOOLS_FIND_ACTION_FINDER_REQUIRED", [
      "argument `action` is missing and must be a valid action",
    ]);
  }
  if (!finder) {
    throw utils.error("TOOLS_FIND_FINDER_REQUIRED", [
      "argument `finder` is missing and must be a function",
    ]);
  }
  if (typeof finder !== "function") {
    throw utils.error("TOOLS_FIND_FINDER_INVALID", [
      "argument `finder` is missing and must be a function",
    ]);
  }
  return [action, finder];
};

export default {
  name: "@nikitajs/core/plugins/tools/find",
  hooks: {
    "nikita:normalize": function (action) {
      action.tools ??= {};
      action.tools.find = async function () {
        const [act, finder] = validate(action, arguments);
        return await find(act, finder);
      };
    },
  },
};
