// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    // Get outdated packages
    const { packages } = await this.tools.npm.outdated({
      cwd: config.cwd,
      global: config.global,
    });
    let outdated = Object.keys(packages).filter((name) => {
      const package = packages[name];
      return package.current !== package.wanted;
    });
    if (config.name) {
      const names = config.name.map((name) => name.split("@")[0]);
      outdated = outdated.filter((name) => names.includes(name));
    }
    // No package to upgrade
    if (!outdated.length) {
      return;
    }
    // Upgrade outdated packages
    await this.execute({
      command: ["npm", "update", config.global ? "--global" : void 0].join(" "),
      cwd: config.cwd,
    });
    log({
      message: `NPM upgraded packages: ${outdated.join(", ")}`,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
