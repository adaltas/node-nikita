
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    await this.docker.tools.execute({
      command: ['restart', config.timeout != null ? `-t ${config.timeout}` : void 0, `${config.container}`].join(' ')
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
