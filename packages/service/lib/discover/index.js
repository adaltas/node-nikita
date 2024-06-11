// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, parent: { state } }) {
    if (state["nikita:service:loader"] != null) {
      return;
    }
    const data = await this.execute({
      $shy: true,
      command: dedent`
        if command -v systemctl >/dev/null; then exit 1; fi ;
        if command -v service >/dev/null; then exit 2; fi ;
        exit 3 ;
      `,
      code: [[1, 2], 3],
    });
    const loader =
      data.code === 1
        ? "systemctl"
        : data.code === 2
        ? "service"
        : undefined;
    if (loader == null && config.strict) {
      throw Error("Undetected Operating System Loader")
    }
    if (config.cache) {
      state["nikita:service:loader"] = loader;
    }
    if (config.cache && loader == null) {
      loader = state["nikita:service:loader"] != null;
    }
    return {
      $status: data.status,
      loader: loader,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
