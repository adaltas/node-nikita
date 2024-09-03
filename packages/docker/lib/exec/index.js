// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    return await this.docker.tools.execute({
      command: [
        "exec",
        config.uid &&
          [`-u ${config.uid}`, config.gid && `:${config.gid}`]
            .filter(Boolean)
            .join(""),
        `${config.container} ${config.command}`,
      ]
        .filter(Boolean)
        .join(" "),
      code: config.code,
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
