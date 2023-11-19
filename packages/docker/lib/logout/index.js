
// Dependencies
import definitions from "./schema.json" assert { type: "json" };
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";

// Action
export default {
  handler: async function({config}) {
    const command = [
      'logout',
      config.registry && esa(config.registry)
    ].filter(Boolean).map(' ');
    await this.docker.tools.execute({
      command: command
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
