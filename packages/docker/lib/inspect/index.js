// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
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
