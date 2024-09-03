// Dependencies
import wait from "@nikitajs/network/tcp/wait";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    let error = null;
    for (const server of config.server) {
      try {
        await this.execute({
          command: `bash -c 'echo > /dev/tcp/${server.host}/${server.port}'`,
        });
        if (config.not === true) {
          error = `Address listening: "${server.host}:${server.port}"`;
          break;
        }
      } catch {
        if (config.not !== true) {
          error = `Address not listening: "${server.host}:${server.port}"`;
          break;
        }
      }
    }
    if (error) {
      throw Error(error);
    }
    return true;
  },
  hooks: {
    on_action: wait.hooks.on_action,
  },
  metadata: {
    shy: true,
    definitions: definitions,
  },
};
