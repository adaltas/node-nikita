
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    await this.docker.tools.execute({
      command: `pause ${config.container}`
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
