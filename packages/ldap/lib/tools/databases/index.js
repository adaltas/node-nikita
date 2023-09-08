// Dependencies
const utils = require("../../utils");
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config }) {
    const { stdout } = await this.ldap.search(config, {
      base: config.base,
      filter: "(objectClass=olcDatabaseConfig)",
      attributes: ["olcDatabase"],
    });
    const databases = utils.string
      .lines(stdout)
      .filter(function (line) {
        return /^olcDatabase: /.test(line);
      })
      .map(function (line) {
        return line.split(" ")[1];
      });
    return {
      databases: databases,
    };
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
