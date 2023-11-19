
// Dependencies
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    await this.execute({
      command: `ln -sf ${esa(config.source)} ${esa(config.target)}`
    });
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
