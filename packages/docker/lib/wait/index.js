
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Old implementation was `wait {container} | read r; return $r`
    await this.docker.tools.execute(`wait ${config.container}`);
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
