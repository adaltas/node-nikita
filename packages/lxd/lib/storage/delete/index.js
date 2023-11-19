// Dependencies
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Check if storage exists
    const {exists} = await this.lxc.storage.exists(config.name);
    if (!exists) return false;
    // Remove the storage
    await this.execute({
      command: `lxc storage delete ${esa(config.name)}`,
      code: [0, 42]
    });
    return true;
  },
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
