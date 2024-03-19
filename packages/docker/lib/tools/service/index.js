
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    await this.docker.run({
      detach: true,
      rm: false,
      ...config
    });
  },
  metadata: {
    definitions: definitions,
    global: "docker",
  }
};
