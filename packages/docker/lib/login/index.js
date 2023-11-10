// Dependencies
const definitions = require("./schema.json");
const utils = require("../../utils");
const esa = utils.string.escapeshellarg;

// Action
module.exports = {
  handler: async function ({ config }) {
    await this.docker.tools.execute({
      command: [
        "login",
        ...["email", "user", "password"]
          .filter(function (opt) {
            return config[opt] != null;
          })
          .map(function (opt) {
            return `-${opt.charAt(0)} ${config[opt]}`;
          }),
        config.registry != null ? `${esa(config.registry)}` : void 0,
      ].join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
