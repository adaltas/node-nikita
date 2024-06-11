// Dependencies
import utils from "@nikitajs/ldap/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    const databases = await this.ldap
      .search({
        ...utils.ldap.config_connection(config),
        base: config.base,
        filter: "(objectClass=olcDatabaseConfig)",
        attributes: ["olcDatabase"],
      })
      .then(({ stdout }) =>
        utils.string
          .lines(stdout)
          .filter(function (line) {
            return /^olcDatabase: /.test(line);
          })
          .map(function (line) {
            return line.split(" ")[1];
          })
      );
    return {
      databases: databases,
    };
  },
  metadata: {
    global: "ldap",
    definitions: definitions,
  },
};
