// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { stdout } = await this.execute({
      command: [
        "npm outdated",
        "--json",
        config.global ? "--global" : void 0,
      ].join(" "),
      code: [0, 1],
      cwd: config.cwd,
      stdout_log: false,
    });
    return {
      packages: JSON.parse(stdout),
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
