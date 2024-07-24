// Dependencies
import utils from "@nikitajs/core/utils";

const walk = async function (action, walker) {
  const precious = await walker(action);
  const results = [];
  if (precious !== undefined) {
    results.push(precious);
  }
  if (action.parent) {
    results.push(...(await walk(action.parent, walker)));
  }
  return results;
};

const validate = function (action, args) {
  let walker;
  if (args.length === 1) {
    [walker] = args;
  } else if (args.length === 2) {
    [action, walker] = args;
  } else {
    if (!action) {
      throw utils.error("TOOLS_WALK_INVALID_ARGUMENT", [
        "action signature is expected to be",
        "`walker` or `action, walker`",
        `got ${JSON.stringify(args)}`,
      ]);
    }
  }
  if (!action) {
    throw utils.error("TOOLS_WALK_ACTION_WALKER_REQUIRED", [
      "argument `action` is missing and must be a valid action",
    ]);
  }
  if (!walker) {
    throw utils.error("TOOLS_WALK_WALKER_REQUIRED", [
      "argument `walker` is missing and must be a function",
    ]);
  }
  if (typeof walker !== "function") {
    throw utils.error("TOOLS_WALK_WALKER_INVALID", [
      "argument `walker` is missing and must be a function",
    ]);
  }
  return [action, walker];
};

export default {
  name: "@nikitajs/core/plugins/tools/walk",
  hooks: {
    "nikita:normalize": function (action) {
      action.tools ??= {};
      // Register tool
      action.tools.walk = async function () {
        const [act, walker] = validate(action, arguments);
        return await walk(act, walker);
      };
    },
  },
};
