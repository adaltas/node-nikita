// Dependencies
import utils from "@nikitajs/ldap/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

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
          }),
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
