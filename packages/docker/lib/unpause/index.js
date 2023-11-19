
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: function({config}) {
    this.docker.tools.execute({
      command: `unpause ${config.container}`
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
