// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
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
      (name) => !installed.includes(name.split("@")[0]),
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
