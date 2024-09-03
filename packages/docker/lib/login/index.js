// Dependencies
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    await this.docker.tools.execute({
      command: [
        "login",
        ...["email", "user", "password"]
          .filter(function (opt) {
            return config[opt] != null;
          })
          .map(function (opt) {
            return `-${opt.charAt(0)} ${config[opt]}`;
          }),
        config.registry != null ? `${esa(config.registry)}` : void 0,
      ].join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
