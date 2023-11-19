
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    // Normalization
    if (config.detach == null) {
      config.detach = true;
    }
    if (config.rm == null) {
      config.rm = false;
    }
    // Execution
    await this.docker.run(config);
  },
  metadata: {
    definitions: definitions,
    global: "docker",
  }
};
