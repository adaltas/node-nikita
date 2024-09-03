// Dependencies
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    // TODO: use nikita.ldap.search
    // Auth related config
    if (config.uri === true) {
      if (config.mesh == null) {
        config.mesh = "EXTERNAL";
      }
      config.uri = "ldapi:///";
    }
    // Add related config
    return await this.execute({
      code: config.code,
      command: [
        "ldapsearch",
        "-o ldif-wrap=no",
        "-LLL", // Remove comments
        config.continuous ? "-c" : undefined,
        config.mesh ? `-Y ${esa(config.mesh)}` : undefined,
        config.binddn ? `-D ${esa(config.binddn)}` : undefined,
        config.passwd ? `-w ${esa(config.passwd)}` : undefined,
        config.uri ? `-H ${esa(config.uri)}` : undefined,
        `-b ${esa(config.base)}`,
        config.scope ? `-s ${esa(config.scope)}` : undefined,
        config.filter ? `${esa(config.filter)}` : undefined,
        ...config.attributes.map(esa),
        "2>/dev/null",
      ]
        .filter(Boolean)
        .join(" "),
    });
  },
  metadata: {
    global: "ldap",
    shy: true,
    definitions: definitions,
  },
};
