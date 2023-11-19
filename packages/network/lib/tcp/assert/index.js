// Dependencies
import definitions from "./schema.json" assert { type: "json" };
import wait from "@nikitajs/network/tcp/wait";

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
          error = `Address listening: \"${server.host}:${server.port}\"`;
          break;
        }
      } catch (err) {
        if (config.not !== true) {
          error = `Address not listening: \"${server.host}:${server.port}\"`;
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
