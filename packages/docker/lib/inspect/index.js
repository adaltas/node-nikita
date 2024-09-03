// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const isCointainerArray = Array.isArray(config.container);
    const { data: info } = await this.docker.tools.execute({
      command: [
        "inspect",
        ...(isCointainerArray ? config.container : [config.container]),
      ].join(" "),
      format: "json",
    });
    return {
      info: isCointainerArray ? info : info[0],
    };
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
