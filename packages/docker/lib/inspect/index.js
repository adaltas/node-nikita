// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    const isCointainerArray = Array.isArray(config.container);
    const { data: info } = await this.docker.tools.execute({
      command: [
        "inspect",
        ...(isCointainerArray ? config.container : [config.container]),
      ].join(" "),
      format: "json",
    });
    return {
      info: isCointainerArray ? info : info[0],
    };
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
