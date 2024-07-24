import utils from "@nikitajs/core/utils";

export default {
  name: "@nikitajs/core/plugins/metadata/relax",
  hooks: {
    "nikita:action": function (action, handler) {
      action.metadata.relax ??= false;
      if (
        typeof action.metadata.relax === "string" ||
        action.metadata.relax instanceof RegExp
      ) {
        action.metadata.relax = [action.metadata.relax];
      }
      if (
        !(
          typeof action.metadata.relax === "boolean" ||
          action.metadata.relax instanceof Array
        )
      ) {
        throw utils.error("METADATA_RELAX_INVALID_VALUE", [
          "configuration `relax` expects a boolean, string, array or regexp",
          `value, got ${JSON.stringify(action.metadata.relax)}.`,
        ]);
      }
      return handler;
    },
    "nikita:result": function (args) {
      if (!args.action.metadata.relax) {
        return;
      }
      if (!args.error) {
        return;
      }
      if (args.error.code === "METADATA_RELAX_INVALID_VALUE") {
        return;
      }
      if (
        args.action.metadata.relax === true ||
        args.action.metadata.relax.includes(args.error.code) ||
        args.action.metadata.relax.some((v) => args.error.code.match(v))
      ) {
        args.output ??= {};
        args.output.error = args.error;
        args.error = undefined;
      }
    },
  },
};
