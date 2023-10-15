// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    // Upgrade
    await this.tools.npm.upgrade({
      $if: config.upgrade,
      cwd: config.cwd,
      global: config.global,
      name: config.name,
    });
    // Get installed packages
    const { packages } = await this.tools.npm.list({
      cwd: config.cwd,
      global: config.global,
    });
    // Install packages
    const installed = Object.keys(packages);
    const install = config.name.filter(
      (name) => !installed.includes(name.split("@")[0])
    );
    if (!install.length) {
      return;
    }
    await this.execute({
      command: [
        "npm install",
        config.global ? "--global" : undefined,
        ...install,
      ].join(" "),
      cwd: config.cwd,
    });
    return log({
      message: `NPM Installed Packages: ${install.join(", ")}`,
    });
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
